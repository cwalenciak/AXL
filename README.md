
![](https://github.com/cwalenciak/AXL/blob/main/AXL%20Logo.png)

## Toolkit for Data Processing & Transformations

AXL is a native Excle VBA library that lives inside of a class module. It allows you to quickly grab data from worksheets where the class module is located, or external workbooks, csv and text files.

- Easy to understand syntax
- Work with header names instead of indexes
- Easily develop data processing and tranformation pipelines 
- Send workflows to whoever has access to Excel to be reused


### Instillation:
Download the AXL.cls and import it into a workbook


### Required References:
- Microsoft Scripting Runtime
- Microsfot Forms 2.0 Object Library

### How to use:

```
dim ax as AXL
set ax = New AXL

dim df
df = hx.GetData(workbook path)
```

Functions List:
[link](./https://github.com/cwalenciak/AXL/edit/main/Axl%20Guid.md#section-name)
