
int cnt = 8;

int[][] Value = new int[4][101];
int[][] DP = new int[4][101];

void setup() {
  int i, j;

  for (i = 0; i < 3; i++) {
    for (j = 0; j < cnt; j++) {
      Value[i][j] = (int)random(-10, 10);
    }
  }

  for (i = 0; i < 3; i++) {
    for (j = 0; j < cnt; j++) {
      System.out.printf("%+05d ", Value[i][j]);
    }
    println();
  }

  for (i = 0; i < cnt; i++) {
    Value[3][i] = Value[0][i] + Value[2][i];
  }

  DP[0][0] = Value[0][0];
  DP[1][0] = Value[1][0];
  DP[2][0] = Value[2][0];
  DP[3][0] = Value[3][0];

  for (i = 1; i < cnt; i++) {
    DP[0][i] = max(DP[1][i - 1], DP[2][i - 1]) + Value[0][i];
    DP[1][i] = max(max(DP[0][i - 1], DP[2][i - 1]), DP[3][i - 1]) + Value[1][i];
    DP[2][i] = max(DP[0][i - 1], DP[1][i - 1]) + Value[2][i];
    DP[3][i] = DP[1][i - 1] + Value[3][i];
  }

  println();

  println(max(
    max(DP[0][cnt - 1], DP[1][cnt - 1]),
    max(DP[2][cnt - 1], DP[3][cnt - 1])
  ));
}
