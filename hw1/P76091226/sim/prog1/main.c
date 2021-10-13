extern int _test_start;
extern int array_size;
extern int array_addr;

void swap(int *a, int *b) {
  int temp = *a;
  *a = *b;
  *b = temp;
}

void selectionSort(int arr[], int n, int test[]){
  int i, j, min_idx;
  for(i = 0; i < n-1 ; i++){
    min_idx = i;
    for(j = i+1 ; j < n ; j++)
      if(arr[j] < arr[min_idx])
        min_idx = j;
    swap(&arr[min_idx], &arr[i]);
    test[i] = arr[i];
  }
  test[n-1] = arr[n-1];
}

int main(void){
  selectionSort(&array_addr, array_size, &_test_start);
  return 0;
}
