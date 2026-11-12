
import java.util.ArrayList;
import java.util.Queue;
import java.util.LinkedList;

int V;

ArrayList<ArrayList<Integer>> adj =
  new ArrayList<ArrayList<Integer>>();

Queue<Integer> q = new LinkedList<Integer>();
ArrayList<Integer> res = new ArrayList<Integer>();

boolean[] visited;

float[] posX;
float[] posY;

int[] parent;
int[] depth;
int[] degree;

int current = -1;
int graphType = 0;
boolean finished = false;

void setup() {
  size(900, 650);
  textAlign(CENTER, CENTER);
  textFont(createFont("SansSerif", 18));

  generateGraph();
}

void generateGraph() {

  // 정점 개수 6~10개 랜덤
  V = (int)random(6, 11);

  visited = new boolean[V];
  posX = new float[V];
  posY = new float[V];

  parent = new int[V];
  depth = new int[V];
  degree = new int[V];

  adj.clear();

  for (int i = 0; i < V; i++) {
    adj.add(new ArrayList<Integer>());
    parent[i] = -1;
    depth[i] = 0;
    degree[i] = 0;
  }

  // 그래프 유형 랜덤 선택
  graphType = (int)random(4);

  if (graphType == 0) {
    generateTree();
  } else {
    arrangeNodes();
    generateRandomEdges();
    connectAllNodes();
  }

  startBFS();
}

// 랜덤 트리 생성
void generateTree() {

  for (int i = 1; i < V; i++) {
    int p = (int)random(i);

    parent[i] = p;
    depth[i] = depth[p] + 1;

    addEdge(i, p);
  }

  float[] nextX = {0};

  positionTree(0, nextX);
  normalizeTree();
}

// 트리 위치 재귀 계산
void positionTree(int node, float[] nextX) {

  int childCount = 0;

  for (int i = 1; i < V; i++) {
    if (parent[i] == node) {
      childCount++;
    }
  }

  if (childCount == 0) {
    posX[node] = nextX[0];
    nextX[0] += 1;
  } else {

    float first = -1;
    float last = -1;

    for (int i = 1; i < V; i++) {
      if (parent[i] == node) {

        positionTree(i, nextX);

        if (first < 0) {
          first = posX[i];
        }

        last = posX[i];
      }
    }

    posX[node] = (first + last) / 2;
  }

  int maxDepth = 0;

  for (int i = 0; i < V; i++) {
    maxDepth = max(maxDepth, depth[i]);
  }

  posY[node] = map(
    depth[node], 0, max(1, maxDepth), 90, 420
  );
}

// 트리 X 좌표 정규화
void normalizeTree() {

  float minX = Float.MAX_VALUE;
  float maxX = -Float.MAX_VALUE;

  for (int i = 0; i < V; i++) {
    minX = min(minX, posX[i]);
    maxX = max(maxX, posX[i]);
  }

  for (int i = 0; i < V; i++) {
    if (maxX == minX) {
      posX[i] = width / 2;
    } else {
      posX[i] = map(
        posX[i], minX, maxX, 90, width - 90
      );
    }
  }
}

// 트리가 아닌 그래프 위치 생성
void arrangeNodes() {

  int[] order = new int[V];

  for (int i = 0; i < V; i++) {
    order[i] = i;
  }

  // 정점 위치를 랜덤으로 섞기
  for (int i = V - 1; i > 0; i--) {
    int j = (int)random(i + 1);

    int temp = order[i];
    order[i] = order[j];
    order[j] = temp;
  }

  for (int i = 0; i < V; i++) {

    int node = order[i];

    if (graphType == 1) {

      // 격자형
      int col = i % 4;
      int row = i / 4;

      posX[node] = 160 + col * 190;
      posY[node] = 110 + row * 145;

    } else if (graphType == 2) {

      // 좌우 연결형
      int col = i / 5;
      int row = i % 5;

      posX[node] = 250 + col * 400;
      posY[node] = 90 + row * 80;

    } else {

      // 자유 배치형
      int col = i % 5;
      int row = i / 5;

      posX[node] = 110 + col * 165;
      posY[node] = 130 + row * 235;
    }
  }
}

// 랜덤 간선 생성
void generateRandomEdges() {

  ArrayList<int[]> candidates =
    new ArrayList<int[]>();

  for (int i = 0; i < V; i++) {
    for (int j = i + 1; j < V; j++) {

      float d = dist(
        posX[i], posY[i],
        posX[j], posY[j]
      );

      boolean possible = false;

      if (graphType == 1 && d < 300) {
        possible = true;
      }

      if (graphType == 2 &&
          abs(posX[i] - posX[j]) > 300) {
        possible = true;
      }

      if (graphType == 3 && d < 350) {
        possible = true;
      }

      if (possible) {
        candidates.add(new int[]{i, j});
      }
    }
  }

  // 간선 후보 섞기
  for (int i = candidates.size()-1; i > 0; i--) {
    int j = (int)random(i+1);

    int[] temp = candidates.get(i);

    candidates.set(i, candidates.get(j));
    candidates.set(j, temp);
  }

  for (int[] edge : candidates) {

    int a = edge[0];
    int b = edge[1];

    if (degree[a] >= 3 || degree[b] >= 3) {
      continue;
    }

    if (random(1) > 0.5) {
      continue;
    }

    if (crossesExistingEdge(a, b)) {
      continue;
    }

    addEdge(a, b);
  }
}

// 모든 정점 연결
void connectAllNodes() {

  boolean[] connected = new boolean[V];
  Queue<Integer> tempQ = new LinkedList<Integer>();

  connected[0] = true;
  tempQ.add(0);

  while (!tempQ.isEmpty()) {

    int curr = tempQ.poll();

    for (int x : adj.get(curr)) {

      if (!connected[x]) {
        connected[x] = true;
        tempQ.add(x);
      }
    }
  }

  for (int i = 0; i < V; i++) {

    if (!connected[i]) {

      int nearest = -1;
      float bestDist = Float.MAX_VALUE;

      // 간선이 교차하지 않는 연결 먼저 찾기
      for (int j = 0; j < V; j++) {

        if (!connected[j]) continue;

        float d = dist(
          posX[i], posY[i],
          posX[j], posY[j]
        );

        if (d < bestDist &&
            !crossesExistingEdge(i, j)) {

          bestDist = d;
          nearest = j;
        }
      }

      // 적절한 연결이 없다면 가장 가까운 정점
      if (nearest == -1) {

        for (int j = 0; j < V; j++) {

          if (!connected[j]) continue;

          float d = dist(
            posX[i], posY[i],
            posX[j], posY[j]
          );

          if (d < bestDist) {
            bestDist = d;
            nearest = j;
          }
        }
      }

      if (nearest != -1) {
        addEdge(i, nearest);
        connected[i] = true;
      }
    }
  }
}

// 간선 교차 확인
boolean crossesExistingEdge(int a, int b) {

  for (int i = 0; i < V; i++) {

    for (int j : adj.get(i)) {

      if (i >= j) continue;

      if (a == i || a == j ||
          b == i || b == j) continue;

      if (intersect(
        posX[a], posY[a],
        posX[b], posY[b],
        posX[i], posY[i],
        posX[j], posY[j]
      )) {
        return true;
      }
    }
  }

  return false;
}

// 두 선분 교차 판정
boolean intersect(
  float ax, float ay,
  float bx, float by,
  float cx, float cy,
  float dx, float dy
) {

  float d1 = cross(ax, ay, bx, by, cx, cy);
  float d2 = cross(ax, ay, bx, by, dx, dy);
  float d3 = cross(cx, cy, dx, dy, ax, ay);
  float d4 = cross(cx, cy, dx, dy, bx, by);

  return d1*d2 < 0 && d3*d4 < 0;
}

float cross(
  float ax, float ay,
  float bx, float by,
  float cx, float cy
) {
  return (bx-ax)*(cy-ay) - (by-ay)*(cx-ax);
}

// 간선 추가
void addEdge(int a, int b) {

  if (a == b) return;

  if (adj.get(a).contains(b)) return;

  adj.get(a).add(b);
  adj.get(b).add(a);

  degree[a]++;
  degree[b]++;
}

// BFS 초기화
void startBFS() {

  visited = new boolean[V];

  q.clear();
  res.clear();

  current = -1;
  finished = false;

  visited[0] = true;
  q.add(0);
}

// BFS 한 단계 실행
void bfsStep() {

  if (q.isEmpty()) {
    finished = true;
    return;
  }

  current = q.poll();
  res.add(current);

  for (int x : adj.get(current)) {

    if (!visited[x]) {
      visited[x] = true;
      q.add(x);
    }
  }

  if (q.isEmpty()) {
    finished = true;
  }
}

void draw() {

  background(238);

  // 간선 표시
  stroke(55);
  strokeWeight(2.5);

  for (int i = 0; i < V; i++) {

    for (int x : adj.get(i)) {

      if (i < x) {
        line(
          posX[i], posY[i],
          posX[x], posY[x]
        );
      }
    }
  }

  // 정점 표시
  for (int i = 0; i < V; i++) {

    if (i == current) {
      fill(255, 185, 90);
    } else if (res.contains(i)) {
      fill(135, 200, 145);
    } else if (visited[i]) {
      fill(145, 185, 240);
    } else {
      fill(238);
    }

    stroke(55);
    strokeWeight(3);

    ellipse(posX[i], posY[i], 42, 42);

    fill(25);
    textSize(18);
    text(i, posX[i], posY[i]);
  }

  // 하단 탐색 정보
  fill(35);
  textSize(19);

  text("BFS Visit Order", width/2, 485);

  String order = "";

  for (int x : res) {
    order += x + " ";
  }

  text(order, width/2, 515);

  String queueText = "";

  for (int x : q) {
    queueText += x + " ";
  }

  textSize(16);
  text("Queue : " + queueText, width/2, 555);

  textSize(14);

  if (finished) {
    text("BFS Finished", width/2, 590);
  } else {
    text("SPACE : Next Step", width/2, 590);
  }

  text(
    "R : Restart    N : New Random Graph",
    width/2, 625
  );
}

// 키보드 조작
void keyPressed() {

  if (key == ' ') {
    if (!finished) {
      bfsStep();
    }
  }

  if (key == 'r' || key == 'R') {
    startBFS();
  }

  if (key == 'n' || key == 'N') {
    generateGraph();
  }
}
