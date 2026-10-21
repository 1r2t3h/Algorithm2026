int n = 8; //<>//

int xstep = 400;
int ystep = 50;
int radius = 30;

int mode = 0;

int traversal = 0;

int textcolor = 0;

PFont font;

BTree tree = new BTree();


void setup() {

  size(1200, 600);

  font = loadFont("AgencyFB-Reg-16.vlw");

  textFont(font, 16);
  textAlign(LEFT, CENTER);

  stroke(192, 0, 0);

  newTree();
}


void draw() {
}


void mousePressed() {

  if (mouseButton == LEFT) {

    if (tree.value == -1) {

      int x = (int)(100.0 * mouseX / width);

      tree.insert(x);

      drawTree();
    }

    else {

      tree.remove(tree.value);

      drawTree();
    }
  }
}


void mouseReleased() {

  drawTree();
}


void mouseMoved() {

  tree.findNode();

  if (tree.value != -1) {

    drawTree();

    fill(92);

    ellipse(
      tree.x,
      tree.y,
      radius,
      radius
    );

    fill(0);

    text(
      tree.value,
      tree.x,
      tree.y
    );
  }

  else {

    drawTree();
  }
}


void keyPressed() {

  if (key == 'c') {

    tree.clear();

    drawTree();
  }

  else if (key == 'v' || key == ' ') {

    drawTree();

    tree.printTree();
  }

  else if (key == 'b') {

    newTree();
  }

  else if (key == 't') {

    traversal++;

    if (traversal >= 3)
      traversal = 0;

    drawTree();
  }

  else if (key == 'd') {

    if (textcolor == 0)
      textcolor = 1;

    else
      textcolor = 0;

    drawTree();
  }

  else if (key == 's') {

    int searchValue =
      (int)(100.0 * mouseX / width);

    Node result =
      tree.search(searchValue);

    drawTree();

    if (result != null) {

      println(
        "찾음 : " +
        result.val
      );

      fill(0, 200, 0);

      ellipse(
        result.x * xstep + width / 2,
        result.y * ystep + radius,
        radius + 10,
        radius + 10
      );

      fill(0);

      text(
        result.val,
        result.x * xstep + width / 2,
        result.y * ystep + radius
      );

      fill(0);

      textAlign(LEFT, CENTER);

      text(
        "Search : " +
        searchValue +
        " FOUND",
        250,
        height - 50
      );

      textAlign(CENTER, CENTER);
    }

    else {

      println(
        searchValue +
        "을 찾을 수 없습니다."
      );

      fill(0);

      textAlign(LEFT, CENTER);

      text(
        "Search : " +
        searchValue +
        " NOT FOUND",
        250,
        height - 50
      );

      textAlign(CENTER, CENTER);
    }
  }
}


void newTree() {

  tree.clear();

  for (int i = 0; i < n; i++) {

    tree.insert(
      (int)random(99)
    );
  }

  drawTree();
}


void drawMode() {

  int x = 20;
  int y = 50;

  textFont(font, 24);

  textAlign(LEFT, CENTER);

  noStroke();

  fill(132);

  rect(
    10,
    height - y - 12,
    102,
    26
  );

  fill(0);

  if (traversal == 0) {

    text(
      "inorder(t)",
      x,
      height - y
    );
  }

  else if (traversal == 1) {

    text(
      "preorder(t)",
      x,
      height - y
    );
  }

  else if (traversal == 2) {

    text(
      "postorder(t)",
      x,
      height - y
    );
  }

  text(
    (int)(100.0 * mouseX / width)
    + " insert",
    x + 110,
    height - y
  );

  text(
    "clear:c   new:b   traversal:v/space   change:t   search:s",
    x,
    height - 24
  );

  stroke(192, 0, 0);

  textFont(font, 16);

  textAlign(CENTER, CENTER);
}


void drawTree() {

  background(200);

  tree.assignPosition();

  tree.drawTree();

  drawMode();
}


class BTree {

  Node root;

  int x;
  int y;
  int value;

  int index;


  void clear() {

    root = null;
  }


  Node search(int key) {

    return search(
      root,
      key
    );
  }


  Node search(
    Node curr,
    int key
  ) {

    if (curr == null) {

      return null;
    }

    if (key == curr.val) {

      return curr;
    }

    if (key < curr.val) {

      return search(
        curr.left,
        key
      );
    }

    else {

      return search(
        curr.right,
        key
      );
    }
  }


  boolean contains(int key) {

    return search(key) != null;
  }


  int findMin() {

    if (isEmpty()) {

      println(
        "The tree is empty"
      );

      return 0;
    }

    return findMin(root).val;
  }


  Node findMin(Node curr) {

    if (curr == null)
      return null;

    if (curr.left == null)
      return curr;

    return findMin(
      curr.left
    );
  }


  int findMax() {

    if (isEmpty()) {

      println(
        "The tree is empty"
      );

      return 0;
    }

    return findMax(root).val;
  }


  Node findMax(Node curr) {

    if (curr == null)
      return null;

    if (curr.right == null)
      return curr;

    return findMax(
      curr.right
    );
  }


  boolean isEmpty() {

    return root == null;
  }


  int treeHeight() {

    return treeHeight(root);
  }


  int treeHeight(Node curr) {

    if (curr == null)
      return -1;

    return 1 +
      max(
        treeHeight(curr.left),
        treeHeight(curr.right)
      );
  }


  boolean insert(int value) {

    if (root == null) {

      root =
        new Node(value);

      return true;
    }

    return insert(
      root,
      value
    );
  }


  boolean insert(
    Node curr,
    int value
  ) {

    if (value == curr.val) {

      return false;
    }

    if (value < curr.val) {

      if (curr.left == null) {

        curr.left =
          new Node(value);

        return true;
      }

      return insert(
        curr.left,
        value
      );
    }

    else {

      if (curr.right == null) {

        curr.right =
          new Node(value);

        return true;
      }

      return insert(
        curr.right,
        value
      );
    }
  }


  void remove(int value) {

    root =
      remove(
        root,
        value
      );
  }


  Node remove(
    Node curr,
    int value
  ) {

    if (curr == null) {

      return null;
    }

    if (value < curr.val) {

      curr.left =
        remove(
          curr.left,
          value
        );
    }

    else if (value > curr.val) {

      curr.right =
        remove(
          curr.right,
          value
        );
    }

    else {

      if (
        curr.left == null &&
        curr.right == null
      ) {

        return null;
      }

      if (curr.left == null) {

        return curr.right;
      }

      if (curr.right == null) {

        return curr.left;
      }

      Node successor =
        findMin(curr.right);

      curr.val =
        successor.val;

      curr.right =
        remove(
          curr.right,
          successor.val
        );
    }

    return curr;
  }


  void assignPosition() {

    if (!isEmpty()) {

      assignPosition(
        root,
        0,
        0
      );
    }
  }


  void assignPosition(
    Node curr,
    float dx,
    float dy
  ) {

    if (curr == null)
      return;

    assignPosition(
      curr.left,
      dx - 1.0 /
      pow(2.0, dy + 1),
      dy + 1
    );

    curr.x = dx;
    curr.y = dy;

    assignPosition(
      curr.right,
      dx + 1.0 /
      pow(2.0, dy + 1),
      dy + 1
    );
  }


  void printTree() {

    fill(0, 0, 255);

    index = 0;

    if (isEmpty()) {

      println(
        "The tree is empty"
      );

      return;
    }

    printTree(root);

    println();
  }


  void printTree(Node curr) {

    if (curr == null)
      return;

    if (traversal == 0) {

      printTree(
        curr.left
      );

      visit(curr);

      printTree(
        curr.right
      );
    }

    else if (traversal == 1) {

      visit(curr);

      printTree(
        curr.left
      );

      printTree(
        curr.right
      );
    }

    else if (traversal == 2) {

      printTree(
        curr.left
      );

      printTree(
        curr.right
      );

      visit(curr);
    }
  }


  void visit(Node curr) {

    println(
      curr.val +
      " " +
      index +
      " (" +
      curr.x +
      "," +
      curr.y +
      ")"
    );

    fill(0, 0, 255);

    text(
      index,

      (int)(
        curr.x *
        xstep +
        width / 2 -
        radius / 2 -
        2
      ),

      (int)(
        curr.y *
        ystep +
        radius -
        radius / 2 -
        2
      )
    );

    index++;
  }


  void findNode() {

    x = -1;
    y = -1;
    value = -1;

    if (isEmpty())
      return;

    findNode(root);
  }


  void findNode(Node curr) {

    if (curr == null)
      return;

    findNode(curr.left);

    int dx =
      mouseX -
      (int)(
        curr.x *
        xstep +
        width / 2
      );

    int dy =
      mouseY -
      (int)(
        curr.y *
        ystep +
        radius
      );

    if (
      dx * dx +
      dy * dy <
      radius * radius / 4
    ) {

      x =
        (int)(
          curr.x *
          xstep +
          width / 2
        );

      y =
        (int)(
          curr.y *
          ystep +
          radius
        );

      value =
        curr.val;

      return;
    }

    findNode(curr.right);
  }


  void drawTree() {

    if (isEmpty()) {

      println(
        "The tree is empty"
      );

      return;
    }

    drawTreeLine(root);

    drawTree(root);
  }


  void drawTreeLine(Node curr) {

    if (curr == null)
      return;

    drawTreeLine(
      curr.left
    );

    if (curr.left != null) {

      line(
        curr.x * xstep +
        width / 2,

        curr.y * ystep +
        radius,

        curr.left.x *
        xstep +
        width / 2,

        curr.left.y *
        ystep +
        radius
      );
    }

    if (curr.right != null) {

      line(
        curr.x *
        xstep +
        width / 2,

        curr.y *
        ystep +
        radius,

        curr.right.x *
        xstep +
        width / 2,

        curr.right.y *
        ystep +
        radius
      );
    }

    drawTreeLine(
      curr.right
    );
  }


  void drawTree(Node curr) {

    if (curr == null)
      return;

    drawTree(
      curr.left
    );

    fill(255);

    ellipse(
      curr.x *
      xstep +
      width / 2,

      curr.y *
      ystep +
      radius,

      radius,
      radius
    );

    if (textcolor == 0)
      fill(0);

    else
      fill(255);

    text(
      curr.val,

      curr.x *
      xstep +
      width / 2,

      curr.y *
      ystep +
      radius
    );

    drawTree(
      curr.right
    );
  }
}


class Node {

  int val;

  float x;
  float y;

  Node left;
  Node right;


  Node(int value) {

    val = value;
  }


  Node(
    int value,
    Node leftNode,
    Node rightNode
  ) {

    val = value;

    left =
      leftNode;

    right =
      rightNode;
  }


  public String toString() {

    if (
      left == null &&
      right == null
    ) {

      return
        "N(" +
        val +
        ")";
    }

    return
      "N(" +
      val +
      ", " +
      left +
      ", " +
      right +
      ")";
  }
}
