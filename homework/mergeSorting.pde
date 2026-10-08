int[] arr;

void setup() {
  intArr(16);
  printArr();
  mergeSorting(arr, 0, arr.length - 1);
  printArr();
}

void intArr(int n) {
  int i;
  arr = new int[n];
  for (i = 0; i<arr.length; i++) {
    arr[i] = (int)random(100);
  }
}

void printArr() {
  int i;
  for (i = 0; i<arr.length; i++) {
    print(arr[i], " ");
  }
  println();
}

void mergeSorting(int[] arr, int p, int r) {
  if (p >= r) return;
  int q = (p + r) / 2;
  mergeSorting(arr, p, q);
  mergeSorting(arr, q + 1, r);
  merge(arr, p, q, r);
}

void merge(int[] arr, int p, int q, int r) {
  int[] temp = new int[r - p + 1];
  int i = p;
  int j = q + 1;
  int k = 0;
  while (i <= q && j <= r) {
    if (arr[i] <= arr[j]) {
      temp[k] = arr[i];
      i++;
    }
    else {
      temp[k] = arr[j];
      j++;
    }
    k++;
  }

  while (i <= q) {
    temp[k] = arr[i];
    i++;
    k++;
  }

  while (j <= r) {
    temp[k] = arr[j];
    j++;
    k++;
  }
  
  for (int n = 0; n < temp.length; n++) {
    arr[p + n] = temp[n];
  }
}

void draw(){
}
