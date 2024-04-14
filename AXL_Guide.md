## Functions List
[AbsVal](#AbsVal)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## AbsVal
Applies an absolute value function to each element in the dataframe for the specified columns.

```
AddCols(ByVal df, ByVal ColNames)
```

#### Agruments:
- **df**: Dataframe <br/>
- **cols**: Column or columns to apply the absolute to

#### Returns:
A dataframe

[Back to Top](#Functions-List)

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

#### Returns:
A dataframe

[Back to Top](#Functions-List)

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

#### Returns:
A dataframe

[Back to Top](#Functions-List)

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
 
#### Returns:
A dataframe

[Back to Top](#Functions-List)

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
  
#### Returns:
A dataframe

[Back to Top](#Functions-List)

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
- **infront (optional)**: Boolean to indicate if the supplied item should be appended to the fron of each element. If true is passed then the item supplied will be appended in the front.

#### Returns:
A dataframe

[Back to Top](#Functions-List)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## ArrayAppend
Appends an array with a supplied item. Returns an array.

```
ArrayAppend(ByVal arr, items)
```
#### Agruments:
- **arr**: Array <br/>
- **col**: Column that contains the elements to be appened. <br/>

#### Returns:
An array

[Back to Top](#Functions-List)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## ArrayAppendElem
Appends each element in an array

```
ArrayAppendElem(ByVal arr, item, Optional infront = False)
```

#### Agruments:
- **arr**: Array <br/>
- **item**: String to be appended to the elements. <br/>
- **infront (optional)**: Boolean to indicate if the supplied item should be appended to the fron of each element. If true is passed then the item supplied will be appended in the front.

#### Returns:
An array

[Back to Top](#Functions-List)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## ArrayCombine
Combines two arrays into one. 

```
ArrayCombine(ByVal arr1, ByVal arr2)
```

#### Agruments:
- **arr1**: First array. Elements of this array will come first in the new array. <br/>
- **arr2**: Second array. Elements of this array will come after the first array elements in the new array. <br/>

#### Returns:
An array

[Back to Top](#Functions-List)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## ArrayDrop
Drop a specific index in an array.

```
Function ArrayDrop(ByVal arr, index)
```

#### Agruments:
- **arr**: Array that will have an index dropped. <br/>
- **index**: Index to be dropped. <br/>

#### Returns:
An array

[Back to Top](#Functions-List)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)

## ArrayPrint
Prints out the elements of an array.

```
ArrayPrint(ByVal arr)
```

#### Agruments:
- **arr**: Array that will have its elements printed out. <br/>

#### Returns:
An array

[Back to Top](#Functions-List)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)


## ArrayReplace
Replaced a specific element of an array with a replacement element.

```
ArrayReplace(arr, findElem, replaceElem)
```

#### Agruments:
- **arr**: Array that will have its elements printed out. <br/>
- **findElem**: Element to replace. <br/>
- **replaceElem**: Replacement element. <br/>

#### Returns:
An array

[Back to Top](#Functions-List)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)


## CastTo
Cast a columns elements to a different type.

```
ArrayReplace(arr, findElem, replaceElem)
```

#### Agruments:
- **df**: Dataframe <br/>
- **col**: Column that contains the elements to change types. <br/>
- **typeToCast**: A enumeration selection of available types to cast your elements to. <br/>

#### Returns:
A dataframe

[Back to Top](#Functions-List)


---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)


## ChangeCell
Change a specific element of a dataframe

```
ChangeCell(ByVal df, ByVal col, ByVal row, item)
```

#### Agruments:
- **df**: Dataframe <br/>
- **col**: Column that contains the cell you want to change. <br/>
- **row**: Row that contains the cell you want to change. <br/>
- **item**: Item you want to change the old cell element to. <br/>

#### Returns:
A dataframe

[Back to Top](#Functions-List)

---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)


## ChangeQty
Calculate the change of a column by shifting the data down and getting the difference. A new columne will be created.

```
ChangeQty(ByVal df, valueCol, Optional groupCol, Optional percChg = False, Optional name = "Chg")
```

#### Agruments:
- **df**: Dataframe <br/>
- **valueCol**: Column whose change will be calculated off of . <br/>
- **groupCol (optional)**: Column that will group values to calculate the change. Change will only be calculated withing a group <br/>
- **percChg (optional)**: Boolean to indicate if the change chould be a percentage. <br/>

#### Returns:
A dataframe

[Back to Top](#Functions-List)



---

[comment]: <> (==============================================================================)
[comment]: <> (==============================================================================)


## ColMean
Calculate the mean of a column.

```
ColMean(ByVal df, col)
```

#### Agruments:
- **df**: Dataframe <br/>
- **col**: Column whose mean will be calculated. <br/>

#### Returns:
A scalar

[Back to Top](#Functions-List)

