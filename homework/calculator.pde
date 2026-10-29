
import java.util.Stack;
import java.util.ArrayList;

String infix = "(12+8)*3";
String postfix = "";
String answer = "";
String message = "Type an expression and press ENTER";
ArrayList<String> history = new ArrayList<String>();
boolean editing = true;
ExprNode root = null;
int layoutIndex = 0;
int leafCount = 0;
int maxDepth = 0;

void setup() {
  size(1160, 780);
  textFont(createFont("SansSerif", 18));
  convert();
}

void draw() {
  background(245);
  fill(25);
  textSize(30);
  text("Infix to Postfix Calculator", 38, 53);
  textSize(15);
  fill(90);
  text("Click the input, edit numbers or operators, then press ENTER or CONVERT.", 40, 85);

  fill(255);
  stroke(editing ? color(50, 110, 210) : color(175));
  strokeWeight(2);
  rect(38, 111, 1080, 58, 9);
  fill(25);
  textSize(24);
  text(infix + (editing && frameCount % 60 < 30 ? "|" : ""), 52, 149);

  drawButton(38, 185, 180, 45, "CONVERT");
  drawButton(230, 185, 130, 45, "CLEAR");
  drawButton(372, 185, 135, 45, "BACKSPACE");
  drawButton(520, 185, 160, 45, "EXAMPLE");

  fill(25);
  textSize(19);
  text("Postfix", 40, 274);
  text("Result", 40, 349);
  text("Stack conversion steps", 40, 435);
  text("Expression Tree", 596, 435);
  fill(255);
  stroke(210);
  rect(38, 283, 1080, 42, 7);
  rect(38, 357, 1080, 42, 7);
  fill(30);
  textSize(21);
  text(postfix, 50, 311);
  text(answer, 50, 385);
  fill(80);
  textSize(13);
  text(message, 40, 414);

  stroke(224);
  line(560, 445, 560, 742);
  fill(55);
  textSize(12);
  int lines = min(history.size(), 11);
  for (int i=0; i<lines; i++) {
    text(history.get(i), 43, 465 + i * 24);
  }
  if (history.size() > lines) text("... (" + (history.size()-lines) + " more steps)", 43, 465 + lines * 24);

  if (root != null) drawExpressionTree(root);
  fill(95);
  textSize(12);
  text("Allowed: positive numbers, decimals, + - * / ( ). No unary minus.", 40, 766);
}

void drawButton(int x, int y, int w, int h, String label) {
  fill(227, 235, 245);
  stroke(155, 174, 195);
  strokeWeight(1);
  rect(x, y, w, h, 7);
  fill(25);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(label, x + w/2, y + h/2);
  textAlign(LEFT, BASELINE);
}

void mousePressed() {
  editing = mouseX >= 38 && mouseX <= 1118 && mouseY >= 111 && mouseY <= 169;
  if (mouseY >= 185 && mouseY <= 230) {
    if (mouseX >= 38 && mouseX <= 218) convert();
    else if (mouseX >= 230 && mouseX <= 360) clearInput();
    else if (mouseX >= 372 && mouseX <= 507) backspaceInput();
    else if (mouseX >= 520 && mouseX <= 680) {
      infix = "(12+8)*3";
      convert();
    }
  }
}

void keyPressed() {
  if (keyCode == ENTER || keyCode == RETURN) {
    convert();
    return;
  }
  if (!editing) return;
  if (keyCode == BACKSPACE) {
    backspaceInput();
  } else if (keyCode == DELETE) {
    clearInput();
  } else if ((key >= '0' && key <= '9') || key == '.' ||
             key == '+' || key == '-' || key == '*' || key == '/' ||
             key == '(' || key == ')' || key == ' ') {
    if (infix.length() < 80) infix += key;
  }
}

void clearInput() {
  infix = "";
  postfix = "";
  answer = "";
  history.clear();
  root = null;
  message = "Enter an expression.";
  editing = true;
}

void backspaceInput() {
  if (infix.length() > 0) infix = infix.substring(0, infix.length()-1);
  editing = true;
}

boolean operator(String s) {
  return s.equals("+") || s.equals("-") || s.equals("*") || s.equals("/");
}

int priority(String s) {
  if (s.equals("*") || s.equals("/")) return 2;
  if (s.equals("+") || s.equals("-")) return 1;
  return 0;
}

ArrayList<String> tokenize(String s) {
  ArrayList<String> t = new ArrayList<String>();
  for (int i=0; i<s.length();) {
    char c = s.charAt(i);
    if (c == ' ') { i++; continue; }
    if (Character.isDigit(c) || c == '.') {
      int start = i;
      int dots = 0;
      int digits = 0;
      while (i<s.length() && (Character.isDigit(s.charAt(i)) || s.charAt(i)=='.')) {
        if (s.charAt(i)=='.') dots++;
        else digits++;
        i++;
      }
      if (dots > 1 || digits == 0) throw new RuntimeException("Invalid number.");
      t.add(s.substring(start, i));
    } else if ("+-*/()".indexOf(c)>=0) {
      t.add(""+c);
      i++;
    } else {
      throw new RuntimeException("Invalid character: " + c);
    }
  }
  if (t.size()==0) throw new RuntimeException("Expression is empty.");
  boolean expectingNumber = true;
  int depth = 0;
  for (String x : t) {
    if (x.equals("(")) {
      if (!expectingNumber) throw new RuntimeException("Missing operator before (.");
      depth++;
    } else if (x.equals(")")) {
      if (expectingNumber || depth==0) throw new RuntimeException("Invalid parentheses.");
      depth--;
      expectingNumber = false;
    } else if (operator(x)) {
      if (expectingNumber) throw new RuntimeException("Missing left operand.");
      expectingNumber = true;
    } else {
      if (!expectingNumber) throw new RuntimeException("Missing operator.");
      expectingNumber = false;
    }
  }
  if (depth!=0 || expectingNumber) throw new RuntimeException("Incomplete expression.");
  return t;
}

void convert() {
  postfix = "";
  answer = "";
  history.clear();
  root = null;
  try {
    ArrayList<String> tokens = tokenize(infix);
    Stack<String> operators = new Stack<String>();
    ArrayList<String> output = new ArrayList<String>();
    for (String t : tokens) {
      if (t.equals("(")) {
        operators.push(t);
      } else if (t.equals(")")) {
        while (!operators.empty() && !operators.peek().equals("(")) output.add(operators.pop());
        if (operators.empty()) throw new RuntimeException("Unmatched parenthesis.");
        operators.pop();
      } else if (operator(t)) {
        while (!operators.empty() && operator(operators.peek()) && priority(operators.peek()) >= priority(t)) {
          output.add(operators.pop());
        }
        operators.push(t);
      } else {
        output.add(t);
      }
      history.add("Read " + t + "   |   Output: " + join(output.toArray(new String[0]), " ") + "   |   Stack: " + operators.toString());
    }
    while (!operators.empty()) {
      String op = operators.pop();
      if (op.equals("(")) throw new RuntimeException("Unmatched parenthesis.");
      output.add(op);
    }
    postfix = join(output.toArray(new String[0]), " ");
    root = buildExpressionTree(output);
    answer = formatNumber(evaluateTree(root));
    message = "Converted successfully. Stack top is on the right.";
  } catch (Exception e) {
    postfix = "";
    answer = "";
    root = null;
    message = "Error: " + e.getMessage();
  }
}

double evaluate(ArrayList<String> tokens) {
  Stack<Double> nums = new Stack<Double>();
  for (String t : tokens) {
    if (!operator(t)) {
      nums.push(Double.parseDouble(t));
    } else {
      if (nums.size()<2) throw new RuntimeException("Invalid expression.");
      double b=nums.pop();
      double a=nums.pop();
      if (t.equals("+")) nums.push(a+b);
      if (t.equals("-")) nums.push(a-b);
      if (t.equals("*")) nums.push(a*b);
      if (t.equals("/")) {
        if (b==0) throw new RuntimeException("Division by zero.");
        nums.push(a/b);
      }
    }
  }
  if (nums.size()!=1) throw new RuntimeException("Invalid expression.");
  return nums.pop();
}

class ExprNode {
  String value;
  ExprNode left, right;
  float x, y;
  ExprNode(String value) { this.value = value; }
}

ExprNode buildExpressionTree(ArrayList<String> tokens) {
  Stack<ExprNode> st = new Stack<ExprNode>();
  for (String t : tokens) {
    ExprNode node = new ExprNode(t);
    if (operator(t)) {
      if (st.size() < 2) throw new RuntimeException("Invalid expression tree.");
      node.right = st.pop();
      node.left = st.pop();
    }
    st.push(node);
  }
  if (st.size() != 1) throw new RuntimeException("Invalid expression tree.");
  return st.pop();
}

double evaluateTree(ExprNode node) {
  if (node == null) throw new RuntimeException("Empty tree.");
  if (!operator(node.value)) return Double.parseDouble(node.value);
  double a = evaluateTree(node.left);
  double b = evaluateTree(node.right);
  if (node.value.equals("+")) return a+b;
  if (node.value.equals("-")) return a-b;
  if (node.value.equals("*")) return a*b;
  if (node.value.equals("/")) {
    if (b == 0) throw new RuntimeException("Division by zero.");
    return a/b;
  }
  throw new RuntimeException("Invalid operator.");
}

String formatNumber(double value) {
  if (Double.isNaN(value) || Double.isInfinite(value)) throw new RuntimeException("Result is not finite.");
  if (Math.abs(value) < 0.0000000001) value=0;
  if (value == Math.rint(value) && Math.abs(value)<1e15) return String.valueOf((long)value);
  return String.format(java.util.Locale.US, "%.6f", value).replaceAll("0+$", "").replaceAll("\\.$", "");
}

int countTreeNodes(ExprNode node) {
  if (node == null) return 0;
  return 1 + countTreeNodes(node.left) + countTreeNodes(node.right);
}

int depthTree(ExprNode node) {
  if (node == null) return 0;
  return 1 + max(depthTree(node.left), depthTree(node.right));
}

void assignTreeCoords(ExprNode node, int depth, float minX, float spanX, float topY, float spanY) {
  if (node == null) return;
  assignTreeCoords(node.left, depth+1, minX, spanX, topY, spanY);
  node.x = minX + (++layoutIndex) * spanX / (leafCount+1);
  node.y = topY + depth * spanY / max(1, maxDepth-1);
  assignTreeCoords(node.right, depth+1, minX, spanX, topY, spanY);
}

void drawTreeEdges(ExprNode node) {
  if (node == null) return;
  stroke(143, 158, 174);
  strokeWeight(2);
  if (node.left != null) line(node.x, node.y, node.left.x, node.left.y);
  if (node.right != null) line(node.x, node.y, node.right.x, node.right.y);
  drawTreeEdges(node.left);
  drawTreeEdges(node.right);
}

void drawTreeNodes(ExprNode node) {
  if (node == null) return;
  boolean op = operator(node.value);
  stroke(op ? color(61, 97, 150) : color(150, 165, 180));
  strokeWeight(1);
  fill(op ? color(78, 120, 181) : color(255));
  ellipse(node.x, node.y, 43, 43);
  fill(op ? color(255) : color(25));
  textAlign(CENTER, CENTER);
  textSize(node.value.length() > 5 ? 10 : (node.value.length() > 3 ? 12 : 15));
  text(node.value, node.x, node.y);
  textAlign(LEFT, BASELINE);
  drawTreeNodes(node.left);
  drawTreeNodes(node.right);
}

void drawExpressionTree(ExprNode node) {
  leafCount = countTreeNodes(node);
  maxDepth = depthTree(node);
  layoutIndex = 0;
  assignTreeCoords(node, 0, 580, 550, 481, 236);
  drawTreeEdges(node);
  drawTreeNodes(node);
}
