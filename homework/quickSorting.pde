int[] arr;

void setup() {
  intArr(16);
  printArr();
  quickSorting(arr, 0, arr.length - 1);
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

void quickSorting(int[] arr, int p, int r) {
  if (p < r) {
    int q = partition(arr, p, r);
    quickSorting(arr, p, q - 1);
    quickSorting(arr, q + 1, r);
  }
}
  int partition(int[] arr, int p, int r) {
  int pivot = arr[r];
  int i = p - 1;
  for (int j = p; j < r; j++) {
    if (arr[j] < pivot) {
      i++;
      swap(i, j);
    }
  }
  swap(i + 1, r);
  return i + 1;
}
void swap(int i, int j) {
  int tmp;
  tmp = arr[j];
  arr[j] = arr[i];
  arr[i] = tmp;
}

void draw(){
}
