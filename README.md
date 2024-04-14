
![](https://github.com/cwalenciak/AXL/blob/main/AXL%20Logo.png)

## Toolkit for Data Processing & Transformations

AXL is a native Excle VBA library that lives inside of a class module. It allows you to quickly grab data worksheets where the class module is located, external workbooks, csv and text files

- Easy to understand syntax
- Work with header names instead of indexes
- Easily develop data processing and tranformation pipelines 
- Send workflows to whoever has access to Excel to be reused

### Conventions Used:
- df: This means a 2D array needs to be passed. It stands for dataframe, and is used to better align with other programing languages such as r or Python.
- arr: This means a 1D array needs to be passed.
- col: Singular col, or column, indicates that a scalar value needs to be passed.

### Installation:
Download the AXL.cls and import it into a workbook


### Required References:
- Microsoft Scripting Runtime
- Microsfot Forms 2.0 Object Library

### How to use:

```
dim ax as AXL
set ax = New AXL

dim df
df = ax.GetData(workbook path)
```

### Function List:
AbsVal [a relative link](Axl Guide.md)
