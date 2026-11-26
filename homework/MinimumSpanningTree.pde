
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

String[] labels = {
  "a", "b", "c", "d", "e",
  "f", "g", "h", "i"
};

int V = labels.length;

// PDF 예제와 비슷한 기본 위치
float[] baseX = {
  90, 200, 480, 745, 850,
  745, 480, 200, 340
};

float[] baseY = {
  250, 100, 100, 100, 250,
  400, 400, 400, 250
};

float[] px = new float[V];
float[] py = new float[V];

ArrayList<Edge> edges = new ArrayList<Edge>();

int[] parent = new int[V];
int[] rank = new int[V];

int step = 0;
int selectedCount = 0;
int totalWeight = 0;

Edge currentEdge = null;
boolean finished = false;

String message = "";

// 간선 클래스
class Edge {
  int u, v, w;
  int state;

  // 0 = 검사 전
  // 1 = 선택
  // -1 = 사이클로 제외

  Edge(int u, int v, int w) {
    this.u = u;
    this.v = v;
    this.w = w;
    this.state = 0;
  }
}

void setup() {
  size(1180, 670);
  textAlign(CENTER, CENTER);
  textFont(createFont("SansSerif", 18));

  generateGraph();
}

// 새 그래프 생성
void generateGraph() {

  edges.clear();

  // 정점 위치를 조금씩 변경
  for (int i = 0; i < V; i++) {
    px[i] = baseX[i] + random(-18, 18);
    py[i] = baseY[i] + random(-15, 15);
  }

  // 원본 PDF 예제의 간선 후보
  int[][] possibleEdges = {
    {0, 1},  // a-b
    {0, 7},  // a-h
    {1, 7},  // b-h
    {1, 2},  // b-c
    {7, 8},  // h-i
    {8, 2},  // i-c
    {8, 6},  // i-g
    {7, 6},  // h-g
    {2, 3},  // c-d
    {2, 5},  // c-f
    {3, 5},  // d-f
    {3, 4},  // d-e
    {5, 4},  // f-e
    {6, 5}   // g-f
  };

  // 모든 간선 후보를 저장
  ArrayList<Edge> candidates =
    new ArrayList<Edge>();

  for (int i = 0; i < possibleEdges.length; i++) {

    int a = possibleEdges[i][0];
    int b = possibleEdges[i][1];

    int w = (int)random(1, 21);

    candidates.add(new Edge(a, b, w));
  }

  // 후보 순서를 섞어서
  // 매번 다른 연결 구조 생성
  Collections.shuffle(candidates);

  // 연결 그래프를 만드는 임시 집합
  int[] tempParent = new int[V];

  for (int i = 0; i < V; i++) {
    tempParent[i] = i;
  }

  // 1. 모든 정점을 연결하는 간선 V-1개 생성
  for (Edge e : candidates) {

    int a = findTemp(tempParent, e.u);
    int b = findTemp(tempParent, e.v);

    if (a != b) {

      edges.add(e);
      tempParent[a] = b;
    }
  }

  // 2. 남은 간선 중 일부 랜덤 추가
  for (Edge e : candidates) {

    if (edges.contains(e)) {
      continue;
    }

    if (random(1) < 0.65) {
      edges.add(e);
    }
  }

  // 가중치 오름차순 정렬
  Collections.sort(edges, new Comparator<Edge>() {

    public int compare(Edge a, Edge b) {

      if (a.w != b.w) {
        return a.w - b.w;
      }

      // 가중치가 같으면 정점 번호 순서
      if (a.u != b.u) {
        return a.u - b.u;
      }

      return a.v - b.v;
    }
  });

  resetKruskal();
}

// 그래프 연결 확인용
int findTemp(int[] p, int x) {

  if (p[x] != x) {
    p[x] = findTemp(p, p[x]);
  }

  return p[x];
}

// Kruskal 초기화
void resetKruskal() {

  for (int i = 0; i < V; i++) {
    parent[i] = i;
    rank[i] = 0;
  }

  for (Edge e : edges) {
    e.state = 0;
  }

  step = 0;
  selectedCount = 0;
  totalWeight = 0;

  currentEdge = null;
  finished = false;

  message = "SPACE : Next Step";
}

// FIND-SET
int findSet(int x) {

  if (parent[x] != x) {
    parent[x] = findSet(parent[x]);
  }

  return parent[x];
}

// UNION
void unionSet(int a, int b) {

  a = findSet(a);
  b = findSet(b);

  if (a == b) return;

  if (rank[a] < rank[b]) {
    parent[a] = b;

  } else if (rank[a] > rank[b]) {
    parent[b] = a;

  } else {
    parent[b] = a;
    rank[a]++;
  }
}

// Kruskal 한 단계 실행
void kruskalStep() {

  if (finished) return;

  if (step >= edges.size()) {
    finished = true;
    return;
  }

  currentEdge = edges.get(step);

  int a = currentEdge.u;
  int b = currentEdge.v;

  // 사이클이 발생하지 않으면 선택
  if (findSet(a) != findSet(b)) {

    unionSet(a, b);

    currentEdge.state = 1;
    selectedCount++;

    totalWeight += currentEdge.w;

    message =
      "SELECT : " +
      labels[a] + " - " + labels[b] +
      " (weight " + currentEdge.w + ")";

  } else {

    currentEdge.state = -1;

    message =
      "SKIP (Cycle) : " +
      labels[a] + " - " + labels[b];
  }

  step++;

  // 정점 9개 -> MST 간선 8개
  if (selectedCount == V - 1) {

    finished = true;

    message =
      "MST Completed! Total Weight = " +
      totalWeight;
  }
}

void draw() {

  background(248, 246, 240);

  drawTitle();
  drawEdges();
  drawWeights();
  drawVertices();
  drawEdgeList();
  drawInfo();
}

void drawTitle() {

  fill(25);
  textSize(26);

  text(
    "Kruskal's Algorithm",
    480, 32
  );
}

// 간선 그리기
void drawEdges() {

  for (Edge e : edges) {

    if (e.state == 1) {

      // 선택된 간선
      stroke(105, 175, 165);
      strokeWeight(7);

    } else if (e.state == -1) {

      // 사이클로 제외된 간선
      stroke(210, 105, 105);
      strokeWeight(2);

    } else {

      // 아직 검사하지 않은 간선
      stroke(65);
      strokeWeight(1.5);
    }

    // 현재 검사 중인 간선 강조
    if (e == currentEdge && !finished) {

      stroke(255, 165, 55);
      strokeWeight(6);
    }

    line(
      px[e.u], py[e.u],
      px[e.v], py[e.v]
    );
  }
}

// 간선 가중치 표시
void drawWeights() {

  for (Edge e : edges) {

    float mx = (px[e.u] + px[e.v]) / 2;
    float my = (py[e.u] + py[e.v]) / 2;

    float dx = px[e.v] - px[e.u];
    float dy = py[e.v] - py[e.u];

    float len = sqrt(dx * dx + dy * dy);

    // 간선에서 약간 떨어뜨려 표시
    if (len > 0) {

      mx += (-dy / len) * 18;
      my += (dx / len) * 18;
    }

    rectMode(CENTER);

    noStroke();
    fill(248, 246, 240);

    rect(mx, my, 32, 25, 4);

    fill(25);
    textSize(17);

    text(e.w, mx, my);
  }
}

// 정점 그리기
void drawVertices() {

  for (int i = 0; i < V; i++) {

    boolean inMST = false;

    for (Edge e : edges) {

      if (e.state == 1 &&
          (e.u == i || e.v == i)) {

        inMST = true;
        break;
      }
    }

    if (inMST) {
      fill(166, 210, 205);
    } else {
      fill(210, 225, 222);
    }

    if (currentEdge != null && !finished &&
        (currentEdge.u == i ||
         currentEdge.v == i)) {

      fill(255, 205, 130);
    }

    stroke(35);
    strokeWeight(2);

    ellipse(px[i], py[i], 39, 39);

    fill(20);
    textSize(21);

    text(labels[i], px[i], py[i]);
  }
}

// 간선 목록
void drawEdgeList() {

  fill(235);
  noStroke();

  rectMode(CORNER);
  rect(950, 65, 210, 370, 10);

  fill(25);
  textAlign(LEFT, CENTER);

  textSize(17);
  text("Sorted Edges", 970, 89);

  textSize(15);

  for (int i = 0; i < edges.size(); i++) {

    Edge e = edges.get(i);

    if (e.state == 1) {

      fill(35, 135, 90);

    } else if (e.state == -1) {

      fill(190, 70, 70);

    } else {

      fill(50);
    }

    String s =
      labels[e.u] + " - " +
      labels[e.v] + " : " + e.w;

    text(s, 970, 118 + i * 22);
  }

  textAlign(CENTER, CENTER);
}

// 하단 정보
void drawInfo() {

  rectMode(CORNER);

  noStroke();
  fill(230);

  rect(0, 465, width, 205);

  fill(30);

  textSize(18);
  text(message, width / 2, 490);

  textSize(16);

  text(
    "Checked Edges : " + step +
    " / " + edges.size(),
    width / 2, 528
  );

  text(
    "Selected Edges : " + selectedCount +
    " / " + (V - 1),
    width / 2, 558
  );

  text(
    "MST Total Weight : " + totalWeight,
    width / 2, 588
  );

  textSize(15);

  text(
    "SPACE : Next    R : Restart    N : New Graph    A : Complete",
    width / 2, 636
  );
}

// 키보드 조작
void keyPressed() {

  if (key == ' ') {
    kruskalStep();
  }

  if (key == 'r' || key == 'R') {
    resetKruskal();
  }

  if (key == 'n' || key == 'N') {
    generateGraph();
  }

  if (key == 'a' || key == 'A') {

    while (!finished) {
      kruskalStep();
    }
  }
}
