ArrayList<Array> lists;
Array list, plist, tlist;
int type=0, napTime=100, len=16, index=0, loop=0;
int lastTime;
int[] data, initial;
boolean autoFlag=true;
String[] titles = {"selectionSort", "bubbleSort", "insertionSort", "mergeSort", "quickSort", "heapSort"};
PFont f;

void setup() {
  size(900, 600);
  f = createFont("Arial", 24);
  textFont(f);
  Array start = new Array(len, 0, -1);
  initial = start.arr.clone();
  run(type);
}

void draw() {
  background(200);
  list = lists.get(index);
  list.draw();
  fill(0);
  text("("+nf(list.i0,2)+","+nf(list.j0,2)+") - "+index+"/"+loop
    +" napTime:"+napTime+"(a/s)" + " type:"+type+"(z/x)", 20, height-20);
  text(titles[type], 20, 40);
  // Keep the original graph and status layout; put the legend below the bars.
  textSize(14);
  fill(80, 150, 230);
  rect(20, height-52, 12, 12);
  fill(0);
  text("Basic", 38, height-41);
  fill(255, 100, 100);
  rect(130, height-52, 12, 12);
  fill(0);
  text("Swap / write", 148, height-41);
  fill(255, 210, 70);
  rect(300, height-52, 12, 12);
  fill(0);
  text("Highlight / compare", 318, height-41);
  textSize(24);
  if(autoFlag) nextStep();
}

void nextStep() {
  // 실제 값이 바뀐 프레임은 조금 더 오래 보여준다.
  int waitTime;
  if (index==0 || index==loop) {
    waitTime = 10 * napTime;
  } else if (lists.get(index).exchange) {
    waitTime = 3 * napTime;
  } else {
    waitTime = napTime;
  }

  if(millis()-lastTime < waitTime) return;
  if(index<loop) index++;
  else {
    type = (type+1) % titles.length;
    run(type);
  }
  lastTime = millis();
}

void keyPressed() {
  if(key == ' ') {
    autoFlag = !autoFlag;
    lastTime = millis();
  }
  else if(key == 'a') {
    if(napTime>20) napTime = max(20, napTime-20);
  }
  else if(key == 's') {
    napTime = min(2000, napTime+20);
  }
  else if(key == 'z') {
    if(type>0) { type--; run(type); }
  }
  else if(key == 'x') {
    if(type<titles.length-1) { type++; run(type); }
  }
  else if (key == CODED) {
    if (keyCode == LEFT) {
      if(index>0) index--;
    } else if (keyCode == RIGHT) {
      if(index<loop) index++;
    }
    lastTime = millis();
  }
}

void mousePressed() {
  if(autoFlag) autoFlag=false;
  if(mouseButton == LEFT) {
    if(index>0) index--;
  }
  else if(mouseButton == RIGHT) {
    if(index<loop) index++;
  }
  lastTime = millis();
}

void run(int type) {
  loop = index = 0;
  data = initial.clone();
  lists = new ArrayList<Array>();
  lists.add(new Array(len, data, -1, -1));
  if (type==0) selectionSort();
  else if (type==1) bubbleSort();
  else if (type==2) insertSort();
  else if (type==3) mergeSort();
  else if (type==4) quickSort();
  else if (type==5) heapSort();
  saveStep(-1, -1, false);
  list = lists.get(0);
  lastTime = millis();
}

// Copy each step so rewinding never changes an earlier frame.
void saveStep(int i, int j, boolean exchange) {
  Array frame = new Array(len, data, i, j);
  frame.exchange = exchange;
  lists.add(frame);
  loop = lists.size()-1;
}

void selectionSort() {
  // Original selection method: move the maximum to the right end.
  for (int end=len-1; end>0; end--) {
    int maximum = 0;
    for (int j=1; j<=end; j++) {
      saveStep(maximum, j, false);
      if (data[maximum] < data[j]) maximum = j;
    }
    if (maximum != end) {
      swap(data, maximum, end);
      saveStep(maximum, end, true);
    }
  }
}

void bubbleSort() {
  for (int end=len-1; end>0; end--) {
    boolean changed = false;

    for (int i=0; i<end; i++) {
      // 비교 장면은 저장하지 않는다.
      // 실제로 두 값의 위치가 바뀔 때만 보여준다.
      if (data[i] > data[i+1]) {
        swap(data, i, i+1);
        saveStep(i, i+1, true);
        changed = true;
      }
    }

    if (!changed) break;
  }
}

void insertSort() {
  // 비교 과정은 생략하고 실제 이동만 보여준다.
  for (int i=1; i<len; i++) {
    int j=i;

    while (j>0) {
      if (data[j-1] <= data[j]) break;

      swap(data, j-1, j);
      saveStep(j-1, j, true);
      j--;
    }
  }
}

void mergeSort() {
  mergeSort(0, len-1);
}

void mergeSort(int low, int high) {
  if (low >= high) return;

  int middle = low + (high-low)/2;

  // 나누는 과정은 화면에 계속 표시하지 않고,
  // 실제 병합 결과만 보여준다.
  mergeSort(low, middle);
  mergeSort(middle+1, high);
  merge(low, middle, high);
}

void merge(int low, int middle, int high) {
  int[] temp = data.clone();
  int i=low, j=middle+1;

  for (int k=low; k<=high; k++) {
    if (i<=middle && (j>high || temp[i]<=temp[j])) {
      data[k]=temp[i++];
    } else {
      data[k]=temp[j++];
    }
  }

  // 한 원소씩 쓰는 장면 대신,
  // low~high 구간의 병합이 끝난 결과를 한 번만 보여준다.
  saveStep(low, high, true);
}

void quickSort() {
  quickSort(0, len-1);
}

void quickSort(int low, int high) {
  if (low>=high) return;

  int pivot=data[high];
  int boundary=low;

  for (int j=low; j<high; j++) {
    // pivot과 비교만 하는 프레임은 생략한다.
    if (data[j]<=pivot) {
      if (boundary!=j) {
        swap(data, boundary, j);
        saveStep(boundary, j, true);
      }
      boundary++;
    }
  }

  // pivot이 실제로 이동할 때만 저장한다.
  if (boundary!=high) {
    swap(data, boundary, high);
    saveStep(boundary, high, true);
  }

  quickSort(low, boundary-1);
  quickSort(boundary+1, high);
}

void heapSort() {
  for (int root=len/2-1; root>=0; root--) heapify(len, root);
  for (int end=len-1; end>0; end--) {
    swap(data, 0, end);
    saveStep(0, end, true);
    heapify(end, 0);
  }
}

void heapify(int size, int root) {
  while (2*root+1<size) {
    int child=2*root+1;

    // 두 자식 중 큰 쪽 선택
    if (child+1<size && data[child]<data[child+1]) {
      child++;
    }

    // 비교만 한 장면은 저장하지 않는다.
    if (data[root]>=data[child]) break;

    // 실제 교환만 애니메이션으로 보여준다.
    swap(data, root, child);
    saveStep(root, child, true);
    root=child;
  }
}

void swap(int[] arr, int i, int j) {
  int tmp=arr[j];
  arr[j] = arr[i];
  arr[i] = tmp;
}
