int[] list= new int[100];
int i, j, index, tmp, max;
print(list.length);
println();
for(i=0; i<list.length; i++){
  list[i] = (int)(random(1000));
  print(list[i], " ");
}
println();

for(i=0; i<list.length; i++){
  max = index = -1;
  for(j=0; j<list.length-i-1; j++){
    if(max<list[j]){
      max = list[j];
      index=j;
    }
  }
  if(index != -1){
    tmp=list[j];
    list[j] = max;
    list[index] = tmp;
  }
}

for(i=0; i<list.length; i++){
  print(list[i], " ");
}
println();
line(0,0, 100,100);
