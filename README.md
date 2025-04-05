
# Shaker sort

implementation of shaker sort in NASM. Sorting is applied to a matrix. The matrix is ​​sorted by the maximum numbers in the row. Designed to run on Linux OS.


Also, via the parameter during assembly, you can select the sorting direction (ascending/descending)


## Deployment

To deploy this project run

```bash
  make
```

There is also an equivalent action

```bash
  make sortorder=asc
```

As a result, a program with ascending sorting will be compiled.

You can also choose to sort in descending order.

```bash
  make sortorder=desc
```
