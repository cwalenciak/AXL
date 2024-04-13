## AbsVal
Applies an absolute value function to each element in the dataframe for the specified columns.

```
AddCols(ByVal df, ByVal ColNames)
```

#### Agruments:
- **df**: Dataframe <br/>
- **cols**: Column or columns to apply the absolute to

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## AddCols
Adds columns to the passed dataframe. These columns added will be blank.

```
AddCols(ByVal df, ByVal ColNames)
```

#### Agruments:
- **df**: Dataframe <br/>
- **colNames**: Column or columns names to add

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## AddIndex

Adds index column starting at 1 to the dataframe supplied.

```
AddIndex(ByVal df, Optional indexName As String = "<INDEX>", Optional posOne As Boolean = True)
```

#### Agruments:
- **df**: Dataframe <br/>
- **indexName (optional)**: Name of the index column to be created. Default is <INDEX>. <br/>
- **posOne (optional)**: Boolean to have the index column be in position one in the dataframe. True means to have it as postion 1.

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)


## AddQuarterCol

Adds a quarter column based off of a supplied month column (month must be a text column).

```
AddQuarterCol(ByVal df, ByVal monthCol, Optional colName = "Qtr", Optional prefix = "Q")
```

#### Agruments:
- **df**: Dataframe <br/>
- **monthCol**: Column that will contain the month text to base the quarter off of. <br/>
- **colName (optional)**: Name of the newly created quarter column. Defualt is Qtr. <br/>
- **prefix (optional)**: Will add a prefix to the numerical quarter element. Default is Q.
  
---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## AddTotalRow
Adds a total row at the bottom of your dataframe.

```
AddTotalRow(ByVal df, ByVal numCols)
```

#### Agruments:
- **df**: Dataframe <br/>
- **numCols**: Column or columns to be included in the total. <br/>
  
---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)
## Append
Appends an string to elements of a supplied column.

```
Append(ByVal df, ByVal col, ByVal item, Optional infront As Boolean = False)
```

#### Agruments:
- **df**: Dataframe <br/>
- **col**: Column that contains the elements to be appened. <br/>
- **item**: String to be appended to the elements. <br/>
- **infront (optional)**
  
