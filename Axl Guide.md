## AbsVal
Applies an absolute value function to each element in the dataframe for the specified columns.

```
AddCols(ByVal df, ByVal ColNames)
```

##### Agruments:
- **df**: Dataframe <br/>
- **cols**: Column or columns to apply the absolute to

---

## AddCols
Adds columns to the passed dataframe. These columns added will be blank.

```
AddCols(ByVal df, ByVal ColNames)
```

##### Agruments:
- **df**: Dataframe <br/>
- **colNames**: Column or columns names to add

---

## AddIndex

Adds index column starting at 1 to the dataframe supplied.

```
AddIndex(ByVal df, Optional indexName As String = "<INDEX>", Optional posOne As Boolean = True)
```

##### Agruments:
- **df**: Dataframe <br/>
- **indexName (optional)**: Name of the index column to be created. Default is <INDEX>.
