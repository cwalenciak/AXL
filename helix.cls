VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "helix"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit


'==================================================================================================
'@ Enumerations
'==================================================================================================


Enum ParserOp
    RemoveNonAlpha
    RemoveNonNum
    RemoveNonAphaNum
    RemoveHyphens
    RemoveBlanks
End Enum



Enum ExtractOp
    DayExtract
    MonthExtract
    MonthNameExtract
    YearExtract
End Enum



Enum ComparerOp
    LessThan
    LessThanOrEqualTo
    EqualTo
    GreaterThanOrEqualTo
    GreaterThan
    NotEqual
    InnerExclusive
    InnerInclusive
    OuterExclusive
    OuterInclusive
    Contains
    DoesNotContain
End Enum



Enum MathOp
    Add
    subtract
    Multiply
    divide
    Exponent
    Root
End Enum



'==================================================================================================
'@ AbsVal
'==================================================================================================
Function AbsVal(ByVal df, ByVal col)
    
    col = HeaderIndex(col, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, col) = Abs(df(i, col))
    Next i

    AbsVal = df
    
End Function



'==================================================================================================
'@ AddCols
'==================================================================================================
'# Wrapper function for Reshape() to add columns to end (right side) of passed DataFrame (df).

Function AddCols(ByVal df, ByVal colnames)

    colnames = ScalarToArray(colnames)
    
    If IsEmpty(colnames) Then
        Debug.Print "<!ERROR!> AddCols: No column list provided"
    Else
        
        Dim originalCount
        originalCount = UBound(df, 2)
        
        ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + UBound(colnames) + 1)
        
        '# Fill Headers
        Dim i
        If IsArray(colnames) = True Then
            For i = LBound(colnames) To UBound(colnames)
                df(1, originalCount + 1 + i) = colnames(i)
            Next i
        End If

        AddCols = df
        
'        AddCols = Reshape(df, UBound(df), UBound(df, 2) + UBound(colNames) + 1, colNames)
    End If
    
End Function




'==================================================================================================
'@ AddIndex
'==================================================================================================
'# Add an index to array. Good for when you need to keep the original index.

Function AddIndex(ByVal df, Optional indexColName As String = "<INDEX>")

    df = Reshape(df, UBound(df), UBound(df, 2) + 1, Array(indexColName))
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, UBound(df, 2)) = i - 1
    Next i
    
    AddIndex = df

End Function




'==================================================================================================
'@ AddTotalRow
'==================================================================================================
'# Adds a total row to the bottom of the DataFrame (df).

Function AddTotalRow(ByVal df, ByVal numCols)

    numCols = ScalarToArray(numCols)
    numCols = HeaderIndex(numCols, df)
    
    df = Reshape(df, UBound(df) + 1, UBound(df, 2))
    
    Dim i
    For i = LBound(numCols) To UBound(numCols)
        
        Dim total As Double
        total = 0
        
        Dim j
        For j = LBound(df) + 1 To UBound(df) - 1
            If IsNumeric(df(j, numCols(i))) = True Then
                total = total + df(j, numCols(i))
            End If
        Next j
        
        df(UBound(df), numCols(i)) = total
    
    Next i
    
    AddTotalRow = df
    
End Function




'==================================================================================================
'@ Append
'==================================================================================================
'# Appends item to a column element.

Function Append(ByVal df, _
                ByVal col, _
                ByVal item, _
                Optional infront As Boolean = False)
    
    col = HeaderIndex(col, df)
    
    Dim i
    
    If infront = False Then
        For i = LBound(df) + 1 To UBound(df)
            df(i, col) = df(i, col) & item
        Next i
    Else
        For i = LBound(df) + 1 To UBound(df)
            df(i, col) = item & df(i, col)
        Next i
    End If
    
    Append = df

End Function




'==================================================================================================
'@ Arrange
'==================================================================================================
'# Creates an array of sequenced numbers by start number and count

Private Function Arrange(startNumber, numberCount, Optional step = 1)
       
    ReDim arr(0 To numberCount - 1)
    
    Dim i
    For i = LBound(arr) To UBound(arr)
        arr(i) = startNumber + i * step
    Next i
    
    Arrange = arr

End Function




'==================================================================================================
'@ BlankFill
'==================================================================================================
'# Fills blank column cell with selected fill value

Function BlankFill(ByVal df, ByVal col, Optional fill = "")
    
    col = HeaderIndex(col, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        If Trim(df(i, col)) = "" Then
            df(i, col) = fill
        End If
    Next i
    
    BlankFill = df

End Function




'==================================================================================================
'@ ChangeCell
'==================================================================================================
'# Changes selected cell

Function ChangeCell(ByVal df, _
                    ByVal col, _
                    ByVal row, _
                    item)

    col = HeaderIndex(col, df)
    
    df(row, col) = item
    
    ChangeCell = df

End Function




'==================================================================================================
'@ DropCol
'==================================================================================================
'# Drops selected column

Function DropCol(ByVal df, ByVal cols)
    
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)
    DropCol = DropCol_Logic(df, cols)

'    Dim i
'    For i = UBound(cols) To LBound(cols) Step -1
'        df = MoveCol(df, cols(i), UBound(df, 2))
'    Next i
'
'    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) - UBound(cols) - 1)
'
'    DropCol = df

End Function


Private Function DropCol_Logic(ByVal df, ByVal cols)

    Dim i
    For i = UBound(cols) To LBound(cols) Step -1
        df = MoveCol_Logic(df, cols(i), UBound(df, 2))
    Next i
    
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) - UBound(cols) - 1)
    
    DropCol_Logic = df

End Function



'==================================================================================================
'@ Compare
'==================================================================================================
'# To provide a boolean for comparisons

Private Function Compare(ByVal item1, _
                         ByVal item2, _
                         compareby As ComparerOp, _
                         Optional limit) As Boolean
    
    Dim outcome As Boolean
    outcome = False

    Select Case compareby
        
        Case LessThan
            If (item1 < item2) Then
                outcome = True
            End If

        Case LessThanOrEqualTo
            If (item1 <= item2) Then
                outcome = True
            End If
        
        Case EqualTo
            If (item1 = item2) Then
                outcome = True
            End If
        
        Case GreaterThanOrEqualTo
            If (item1 >= item2) Then
                outcome = True
            End If

        Case GreaterThan
            If (item1 > item2) Then
                outcome = True
            End If

        Case NotEqual
            If (item1 <> item2) Then
                outcome = True
            End If

        Case InnerExclusive
            If (item1 > item2) And (item1 < limit) Then
                outcome = True
            End If
        
        Case InnerInclusive
            If (item1 >= item2) And (item1 <= limit) Then
                outcome = True
            End If
        
        Case OuterExclusive
            If (item1 < item2) And (item1 > limit) Then
                outcome = True
            End If
        
        Case OuterInclusive
            If (item1 <= item2) And (item1 >= limit) Then
                outcome = True
            End If
        
        Case Contains
            If InStr(1, item1, item2) > 0 Then
                outcome = True
            End If

        Case DoesNotContain
            If InStr(1, item1, item2) = 0 Then
                outcome = True
            End If

    End Select
    
    Compare = outcome

End Function




'==================================================================================================
'@ Concat (Concatenate)
'==================================================================================================
'# Combines data from multiple columns into one column

Function Concat(ByVal df, _
                ByVal colToFill, _
                ByVal cols, _
                Optional ByVal seperator As String = "", _
                Optional skipHeader = True)
                     
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim cellVal
    
    Dim i
    For i = LBound(df) + Abs(skipHeader) To UBound(df)
        
        Dim j
        For j = LBound(cols) To UBound(cols)
            If j = LBound(cols) Then
                cellVal = df(i, cols(j))
            Else
                cellVal = cellVal & seperator & df(i, cols(j))
            End If
        Next j
        
        df(i, colToFill) = cellVal
        
    Next i

    Concat = df

End Function



'==================================================================================================
'@ CopyCol - Copies a selected column to new column
'==================================================================================================

Function CopyCol(ByVal df, ByVal colToFill, ByVal colToCopy)
    
    colToFill = HeaderIndex(colToFill, df)
    colToCopy = HeaderIndex(colToCopy, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = df(i, colToCopy)
    Next i
    
    CopyCol = df

End Function



'==================================================================================================
'@CopyColIf
'==================================================================================================
'# Only copies column elemnts if they meet the criteria

Function CopyColIf(ByVal df, _
                   ByVal colToFill, _
                   ByVal colToCopy, _
                   criteria, _
                   ByVal searchCol, _
                   compareby As ComparerOp, _
                   Optional limit)
    
    colToFill = HeaderIndex(colToFill, df)
    colToCopy = HeaderIndex(colToCopy, df)
    searchCol = HeaderIndex(searchCol, df)
    
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
    
        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby, limit)
                                   
        If outcome = True Then
            df(i, colToFill) = df(i, colToCopy)
        End If
        
    Next i
    
    CopyColIf = df
    
End Function



'==================================================================================================
'@ CountIf
'==================================================================================================
'# Counts the number of items in a column that match criteria.

Function CountIf(ByVal df, _
                 ByVal criteria, _
                 ByVal searchCol, _
                 compareby As ComparerOp, _
                 Optional limit)
               
    searchCol = HeaderIndex(searchCol, df)

    Dim total As Double
    
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
        
        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby, limit)
        
        If outcome = True Then
            total = total + 1
        End If
        
    Next i
    
    CountIf = total

End Function



'==================================================================================================
'@ DateExtract
'==================================================================================================
Function DateExtract(ByVal df, _
                     ByVal col, _
                     ByVal colToFill, _
                     ExtractOp As ExtractOp)
    
    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)

        Select Case ExtractOp
        
            Case DayExtract
                If IsDate(df(i, col)) = True Then
                    df(i, colToFill) = Day(df(i, col))
                End If
                
            Case MonthExtract
                If IsDate(df(i, col)) = True Then
                    df(i, colToFill) = Month(df(i, col))
                End If
    
            Case YearExtract
                If IsDate(df(i, col)) = True Then
                    df(i, colToFill) = Year(df(i, col))
                End If
            
            Case MonthNameExtract
                If IsDate(df(i, col)) = True Then
                    df(i, colToFill) = Month(df(i, col))
                    
                    Select Case df(i, colToFill)
                        
                        Case 1
                            df(i, colToFill) = "January"
                        
                        Case 2
                            df(i, colToFill) = "February"
                            
                        Case 3
                            df(i, colToFill) = "March"
                        
                        Case 4
                            df(i, colToFill) = "April"
                        
                        Case 5
                            df(i, colToFill) = "May"
                        
                        Case 6
                            df(i, colToFill) = "June"
                        
                        Case 7
                            df(i, colToFill) = "July"
                        
                        Case 8
                            df(i, colToFill) = "August"
                        
                        Case 9
                            df(i, colToFill) = "September"
                        
                        Case 10
                            df(i, colToFill) = "October"
                        
                        Case 11
                            df(i, colToFill) = "November"
                         
                        Case 12
                            df(i, colToFill) = "December"
                    End Select
                    
                End If

        End Select
    
    Next i

    DateExtract = df
    
End Function



'==================================================================================================
'@ ExportDF
'==================================================================================================
Sub Export(ByVal df, _
           Optional wb As Workbook, _
           Optional ws As Worksheet, _
           Optional startRow = 1, _
           Optional startCol = 1)
            
            
    If wb Is Nothing Then
        Set wb = Workbooks.Add
    End If
            
    If ws Is Nothing Then
        Set ws = ActiveSheet
    End If
    
    Dim EndRow As Long
    EndRow = startRow + UBound(df) - 1
    
    Dim endColumn As Long
    endColumn = startCol + UBound(df, 2) - 1
    
    Dim exportRange As Range
    Set exportRange = ws.Range(ws.Cells(startRow, startCol), ws.Cells(EndRow, endColumn))
             
    exportRange = df

End Sub



'==================================================================================================
'@ FileData
'==================================================================================================

Function FileData(filesFldrPath)

    Dim fso As FileSystemObject
    Set fso = New FileSystemObject
    
    Dim fldr As Folder
    Set fldr = fso.GetFolder(filesFldrPath)
    
    If fldr.Files.count > 0 Then
    
        ReDim df(1 To fldr.Files.count + 1, 1 To 3)
    
        df(1, 1) = "Path"
        df(1, 2) = "Name"
        df(1, 3) = "Extension"
    
        Dim i As Integer
        i = 2
        
        Dim file As file
        For Each file In fldr.Files
            
            Dim extStart
            extStart = InStrRev(file.name, ".")
            
            df(i, 1) = file.path
            df(i, 2) = left(file.name, extStart - 1)
            df(i, 3) = Right(file.name, Len(file.name) - extStart)
        
            i = i + 1
        
        Next file
        
    Else
        ReDim df(1 To 1, 1 To 3)
    End If
    
    FileData = df
    
End Function




'==================================================================================================
'@ FillCol
'==================================================================================================
Function FillCol(ByVal df, ByVal colToFill, item)

    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = item
    Next i

    FillCol = df

End Function



'==================================================================================================
'@ FillColIf
'==================================================================================================
Function FillColIf(ByVal df, _
                   ByVal colToFill, _
                   criteria, _
                   ByVal searchCol, _
                   compareby As ComparerOp, _
                   trueReturn, _
                   Optional limit)

    colToFill = HeaderIndex(colToFill, df)
    searchCol = HeaderIndex(searchCol, df)
    
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
    
        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby, limit)
                                   
        If outcome = True Then
            df(i, colToFill) = trueReturn
        End If
        
    Next i
   
    FillColIf = df

End Function



'==================================================================================================
'@ FillIncr
'==================================================================================================
Function FillIncr(ByVal df, _
                  ByVal colToFill, _
                  Optional start = 1, _
                  Optional incr = 1)

    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = start + incr * (i - 2)
    Next i
   
    FillIncr = df

End Function


'==================================================================================================
'@ Filter
'==================================================================================================
'# Filter DF on specific column

Function Filter(ByVal df, _
                ByVal criteria, _
                ByVal searchCol, _
                compareby As ComparerOp)

'    ReDim tempdf(1 To UBound(df), 1 To UBound(df, 2))

    searchCol = HeaderIndex(searchCol, df)
    Filter = Filter_Logic(df, criteria, searchCol, compareby)
'    Dim n
'    n = 1
'
'    '# Fill Headers
'    Dim i
'    For i = LBound(tempdf, 2) To UBound(tempdf, 2)
'        tempdf(n, i) = df(1, i)
'    Next i
'
'    '# Create New Body Array of Criteria Match
'    For i = LBound(df) + 1 To UBound(df)
'
'        Dim outcome As Boolean
'        outcome = Compare(df(i, searchCol), criteria, compareby)
'
'        If outcome = True Then
'            n = n + 1
'
'            Dim j
'            For j = LBound(tempdf, 2) To UBound(tempdf, 2)
'                tempdf(n, j) = df(i, j)
'            Next j
'
'        End If
'
'    Next i
'
'    '# Assign to New Array with ErrorHandler
'    tempdf = Reshape(tempdf, n, UBound(tempdf, 2))
'
'    Filter = tempdf

End Function


Private Function Filter_Logic(ByVal df, _
                              ByVal criteria, _
                              ByVal searchCol, _
                              compareby As ComparerOp)

    ReDim tempdf(1 To UBound(df), 1 To UBound(df, 2))
    
    Dim n
    n = 1

    '# Fill Headers
    Dim i
    For i = LBound(tempdf, 2) To UBound(tempdf, 2)
        tempdf(n, i) = df(1, i)
    Next i

    '# Create New Body Array of Criteria Match
    For i = LBound(df) + 1 To UBound(df)

        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby)

        If outcome = True Then
            n = n + 1
            
            Dim j
            For j = LBound(tempdf, 2) To UBound(tempdf, 2)
                tempdf(n, j) = df(i, j)
            Next j
            
        End If

    Next i

    '# Assign to New Array with ErrorHandler
'    tempdf = Reshape(tempdf, n, UBound(tempdf, 2))
    tempdf = Reshape_Row_Logic(tempdf, n)
    
    Filter_Logic = tempdf

End Function


Private Function Filter_Fast(ByVal df, _
                             ByVal criteria, _
                             ByVal searchCol)
                             
    Dim n
    n = 0

    '# Create index array and add header index
    ReDim indexArr(0 To UBound(df) - 1)
    indexArr(n) = 1
    
    Dim found
    found = 0
    
    '# Create New Body Array of Criteria Match
    Dim i
    For i = LBound(df) + 1 To UBound(df)

        If (df(i, searchCol) = criteria) Then
            found = 1
            n = n + 1
            indexArr(n) = i
        End If
        
    Next i
    
    ReDim Preserve indexArr(0 To n)
    
    ReDim tempdf(1 To n + 1, 1 To UBound(df, 2))
    
    Dim incr
    incr = 1
    
    Dim index
    For Each index In indexArr
        
        Dim j
        For j = LBound(df, 2) To UBound(df, 2)
            tempdf(incr, j) = df(index, j)
        Next j
        
        incr = incr + 1
        
    Next index
  
    Filter_Fast = tempdf

End Function



'==================================================================================================
'@ Flip
'==================================================================================================
'# Flips data (ascending or descending is sored)

Function Flip(ByVal df)

    ReDim tempdf(1 To UBound(df), 1 To UBound(df, 2))

    Dim pos
    pos = 2

    Dim i
    Dim j
    
    '# Assign Headers
    For j = LBound(df, 2) To UBound(df, 2)
        tempdf(1, j) = df(1, j)
    Next j

    For i = UBound(df) To LBound(df) + 1 Step -1
        For j = LBound(df, 2) To UBound(df, 2)
            tempdf(pos, j) = df(i, j)
        Next j

        pos = pos + 1

    Next i

    Flip = tempdf

End Function



'==================================================================================================
'@ FolderData
'==================================================================================================

Function FolderData(filesFldrPath)

    Dim fso As FileSystemObject
    Set fso = New FileSystemObject
    
    Dim fldr As Folder
    Set fldr = fso.GetFolder(filesFldrPath)
 
    If fldr.SubFolders.count > 0 Then
    
        ReDim df(1 To fldr.SubFolders.count + 1, 1 To 2)
        
        df(1, 1) = "Name"
        df(1, 2) = "Path"
    
        Dim i As Integer
        i = 2
        
        Dim sfldr As Folder
        For Each sfldr In fldr.SubFolders

            df(i, 1) = sfldr.name
            df(i, 2) = sfldr.path
                    
            i = i + 1
        
        Next sfldr

    Else
        ReDim df(1 To 1, 1 To 3)
    End If
    
    FolderData = df
    
End Function


'==================================================================================================
'@GetData
'==================================================================================================
Function GetData(Optional wbPath = "", _
                 Optional wb As Workbook, _
                 Optional wsName As String = "", _
                 Optional startRow As Long = 1, _
                 Optional startCol As Long = 1, _
                 Optional EndRow As Long = 0, _
                 Optional endCol As Long = 0)
    
    If wbPath <> "" Then
        Set wb = Workbooks.Open(wbPath)
    ElseIf IsNull(wb) Then
        Set wb = ActiveWorkbook
    End If
    
    '# Worksheet
    Dim ws As Worksheet
    If wsName <> "" Then
        Set ws = Sheets(wsName)
    Else
        Set ws = ActiveSheet
    End If
    
    '# Column Count
    Dim colcount As Long
    If endCol = 0 Then
        colcount = ws.Cells(startRow, Columns.count).End(xlToLeft).Column
    Else
        colcount = endCol
    End If
    
    '# Row Count
    Dim rowCount As Long
    If EndRow = 0 Then
        Dim i
        For i = startCol To colcount
            Dim tempRow As Long
            tempRow = ws.Cells(rows.count, i).End(xlUp).row
            If tempRow > rowCount Then
                rowCount = tempRow
            End If
        Next i
    Else
        rowCount = EndRow
    End If
    
    GetData = ws.Range(ws.Cells(startRow, startCol), ws.Cells(rowCount, colcount))
    
    If wbPath <> "" Then
        wb.Close
    End If
    
End Function


'==================================================================================================
'@GetElement
'==================================================================================================
Function GetElement(ByVal df, _
                    ByVal col, _
                    ByVal row As Long)

    col = HeaderIndex(col, df)
    GetElement = df(row, col)

End Function




'==================================================================================================
'@ Group
'==================================================================================================
'# Groups data on a given column. Creates a unique list based on the group col.

Function Group(ByVal df, _
               ByVal groupCols, _
               Optional ByVal numCols, _
               Optional sum As Boolean = False, _
               Optional mean As Boolean = False, _
               Optional median As Boolean = False, _
               Optional min As Boolean = False, _
               Optional max As Boolean = False, _
               Optional count As Boolean = True)
    
    groupCols = ScalarToArray(groupCols)
    
    Dim groupColsIndex
    groupColsIndex = HeaderIndex(groupCols, df)
    
    '# Concatenate sort columns (accounts for multip column groups)
    df = Concat(df, groupCols(0), groupCols, "/--/", False)
    
    Dim colcount
    colcount = Abs(sum) + Abs(mean) + Abs(median) + Abs(min) + Abs(max) + Abs(count) + 1
    
    If IsMissing(numCols) = False Then
    
        numCols = ScalarToArray(numCols)
        
        '# Preserving numCols to get names
        colcount = colcount * (UBound(numCols) + 1)


        
        ReDim Preserve numCols(0 To UBound(numCols) + 1)
        numCols(UBound(numCols)) = df(1, groupColsIndex(0))
        
        df = SelectCols(df, numCols)
        ReDim Preserve numCols(0 To UBound(numCols) - 1)
        
        Dim numColsIndex
        numColsIndex = HeaderIndex(numCols, df)
    Else
        df = SelectCols(df, groupCols(0))
    End If

    '# Get Unique Items
    Dim uniqueDf
    uniqueDf = Unique(df, UBound(df, 2))
    
    ReDim tempdf(1 To UBound(uniqueDf), 1 To colcount)
    tempdf(1, 1) = df(1, UBound(df, 2))
    
    Dim stime
    stime = Timer()
    
    Dim i
    For i = LBound(uniqueDf) + 1 To UBound(uniqueDf)
    
        Dim splitDF
        splitDF = Filter_Fast(df, uniqueDf(i, 1), UBound(df, 2))

        Dim colPos
        colPos = 2

        tempdf(i, 1) = uniqueDf(i, 1)

        If IsMissing(numCols) = False Then
                
            Dim j
            For j = LBound(numCols) To UBound(numCols)
    
                If sum Then
                    tempdf(1, colPos) = numCols(j) + "_Sum"
                    tempdf(i, colPos) = SumCols_Logic(splitDF, Array(numColsIndex(j)))
                    colPos = colPos + 1
                End If
            
                If mean Then
                    tempdf(1, colPos) = numCols(j) + "_Mean"
                    tempdf(i, colPos) = SumCols_Logic(splitDF, Array(numColsIndex(j))) / (UBound(splitDF) - 1)
                    colPos = colPos + 1
                End If
                
                If median Then
                    tempdf(1, colPos) = numCols(j) + "_Median"
                    tempdf(i, colPos) = GroupMedian(splitDF, numColsIndex(j))
                    colPos = colPos + 1
                End If
                
                If min Then
                    tempdf(1, colPos) = numCols(j) + "_Min"
                    tempdf(i, colPos) = GroupMinMax(splitDF, numColsIndex(j), False)
                    colPos = colPos + 1
                End If
                
                If max Then
                    tempdf(1, colPos) = numCols(j) + "_Max"
                    tempdf(i, colPos) = GroupMinMax(splitDF, numColsIndex(j))
                    colPos = colPos + 1
                End If
                
            Next j
            
        End If
                
        If count Then
            tempdf(1, colPos) = "Count"
            tempdf(i, colPos) = (UBound(splitDF) - 1)
        End If
 
    Next i
    
    Debug.Print "Filter Time: " & Timer() - stime
    
    '# Add extra split columns to array
    tempdf = Reshape(tempdf, UBound(tempdf), UBound(tempdf, 2) + UBound(groupCols))

    '# Move split columns to start of array (starts in col 2 because we will fill col 1)
    For i = LBound(groupCols) To UBound(groupCols) - 1
        tempdf = MoveCol(tempdf, UBound(tempdf, 2), i + 2)
    Next i

    tempdf = SplitData(tempdf, 1, Arrange(1, UBound(groupCols) + 1), "/--/", False)
    
    Group = tempdf
    
End Function


Private Function GroupMedian(ByVal df, col)
    
    '# The -1 and +1 are for headers because we need n
    df = Sort(df, col)
    
    If (UBound(df) - 1) Mod 2 <> 0 Then
        GroupMedian = df(UBound(df) / 2 + 1, col)
    Else
        Dim temp
        temp = df((UBound(df) - 1) / 2 + 1, col)
        temp = temp + df((UBound(df) + 1) / 2 + 1, col)
        
        GroupMedian = temp / 2
    End If
    
End Function

Private Function GroupMinMax(ByVal df, col, Optional max = True)

    df = Sort(df, col)
    
    If max Then
        GroupMinMax = df(UBound(df), col)
    Else
        GroupMinMax = df(2, col)
    End If
    
End Function





'==================================================================================================
'@HeaderIndex
'==================================================================================================
'# Get header Index for supplied header name

Function HeaderIndex(ByVal colnames, ByVal df)

    If IsArray(colnames) = True Then
        HeaderIndex = HeaderIndexList(colnames, df)
    Else
        HeaderIndex = HeaderIndexScalar(colnames, df)
    End If
    
End Function



'************************************************
'@scalar (*Private*)
'************************************************
'# Purpose:Find header position with given name. If header name is not a string _
'#         then it returns the headerName given (which is the column position)

Private Function HeaderIndexScalar(ByVal colnames, ByVal df)
    
    If IsNumeric(colnames) = False Then
        
        '# Create Array from Header Names
        Dim tempdf
        tempdf = RowToCol(df, 1)
        tempdf = AddIndex(tempdf)

        Sort_Logic tempdf, 1, LBound(tempdf) + 1, UBound(tempdf)

        Dim position
        position = Search_Logic(colnames, tempdf, 1)
        
        If position <> "<!NO POSITION!>" Then
            HeaderIndexScalar = tempdf(position, 2)
        Else
            Debug.Print "<!ERROR!> Header " & colnames & " does NOT exist"
        End If
        
    Else
        HeaderIndexScalar = colnames * 1
    End If
    
End Function


'************************************************
'@list (*Private*)
'************************************************
'# Assigns index to list of header names

Private Function HeaderIndexList(ByVal headerList, ByVal arr)
    
    '# Create temp list to hold transformed headers
    ReDim tempList(0 To UBound(headerList))
    
    Dim i
    For i = LBound(headerList) To UBound(headerList)
    
        If IsNumeric(headerList(i)) = False Then
            tempList(i) = HeaderIndexScalar(headerList(i), arr)
        Else
            tempList(i) = headerList(i)
        End If
    
    Next i
    
    HeaderIndexList = tempList

End Function



'==================================================================================================
'@ InsertTopRow
'==================================================================================================
Function InsertTopRow(ByVal df)

    df = Reshape(df, UBound(df) + 1, UBound(df, 2))
    
    Dim i
    Dim j
    
    For i = UBound(df) To LBound(df) + 1 Step -1
        For j = LBound(df, 2) To UBound(df, 2)
            df(i, j) = df(i - 1, j)
        Next j
    Next i

    '# Clear Top Row
    For j = LBound(df, 2) To UBound(df, 2)
        df(2, j) = ""
    Next j

    InsertTopRow = df

End Function



'==================================================================================================
'@Join
'==================================================================================================

Function Join(ByVal df, _
              ByVal onCols, _
              ByVal joinDF, _
              Optional ByVal joinCols, _
              Optional rightOn, _
              Optional indicator = True)
              
    '# Concatenate Join columns
    onCols = ScalarToArray(onCols)
    
    If IsMissing(rightOn) Then
        rightOn = onCols
    Else
        rightOn = ScalarToArray(rightOn)
    End If
    
    '# If no join columns then all are joined
    If IsMissing(joinCols) Then
    
        Dim colstr
        colstr = ""
        
        Dim i
        For i = LBound(rightOn) To UBound(rightOn)
            colstr = colstr & "//" & rightOn(i)
        Next i
        
        ReDim joinCols(0 To UBound(joinDF, 2) - 2)
        
        Dim incr
        incr = 0
        For i = LBound(joinDF, 2) To UBound(joinDF, 2)
            If InStr(colstr, joinDF(1, i)) = 0 Then
                joinCols(incr) = joinDF(1, i)
                incr = incr + 1
            End If
        Next i
        
    Else
        joinCols = ScalarToArray(joinCols)
    End If
    
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
    df(1, UBound(df, 2)) = "LeftJoinCols"

    df = Concat(df, UBound(df, 2), onCols, "/-/")

    ReDim Preserve joinDF(1 To UBound(joinDF), 1 To UBound(joinDF, 2) + 1)
    joinDF = Concat(joinDF, UBound(joinDF, 2), rightOn, "/-/")
  
    df = Join_Logic(df, UBound(df, 2), joinDF, UBound(joinDF, 2), joinCols, indicator)
    
    df = DropCol(df, "LeftJoinCols")

    Join = df
    
End Function


'************************************************
'@Join_Logic (*Private*)
'************************************************
Private Function Join_Logic(ByVal df, _
                            ByVal leftOn, _
                            ByVal joinDF, _
                            ByVal rightOn, _
                            ByVal joinCols, _
                            Optional indicator = True)
              
    Dim origColCount
    origColCount = UBound(df, 2)
                         
    df = AddCols(df, joinCols)
    
    '# joinCols header search comes after reshape so that Reshape can extract col names
    joinCols = HeaderIndex(joinCols, joinDF)
    
    '#Header Index Match df
    joinDF = Sort(joinDF, Array(rightOn))
    
    If indicator Then
        df = AddCols(df, "_Join")
        df = FillCol(df, "_Join", "left_only")
    End If
    
    Dim i
    Dim j
    
    Dim searchDF
    searchDF = SelectCols(joinDF, rightOn)
   
    For i = LBound(df) + 1 To UBound(df)

        Dim rowPos As Variant
        rowPos = Search_Logic(df(i, leftOn), searchDF, 1)
        
        If rowPos <> "<!NO POSITION!>" Then
            
            For j = LBound(joinCols) To UBound(joinCols)
                df(i, j + origColCount + 1) = joinDF(rowPos, joinCols(j))
            Next j
            
            If indicator Then
                df(i, UBound(df, 2)) = "both"
            End If
        
        End If
       
    Next i
    
    Join_Logic = df

End Function



'==================================================================================================
'@ JoinAppend
'==================================================================================================
'# Appends the joinCol to the appendCol. Good for when you have multiple categories for
'# the same account and want to append them into one coolumn of another array.
'# (e.g. multiple exemptions on the same account)

Function JoinAppend(ByVal df, _
                    ByVal leftOn, _
                    ByVal appendCol, _
                    ByVal joinDF, _
                    ByVal rightOn, _
                    ByVal joinCol, _
                    Optional seperator = "; ")


    If IsArray(joinDF) And UBound(joinDF) > 1 Then
        df = JoinAppend_Logic(df, leftOn, appendCol, joinDF, rightOn, joinCol, seperator)
    End If

    JoinAppend = df

End Function


'************************************************
'@ JoinAppend_Logic(*Private*)
'************************************************
Private Function JoinAppend_Logic(ByVal df, _
                                  ByVal leftOn, _
                                  ByVal appendCol, _
                                  ByVal joinDF, _
                                  ByVal rightOn, _
                                  ByVal joinCol, _
                                  Optional seperator = "; ")

    Dim splitDF
    splitDF = SplitOnCol(joinDF, joinCol)

    '# Header Index Data Array
    leftOn = HeaderIndex(leftOn, df)
    appendCol = HeaderIndex(appendCol, df)

    rightOn = HeaderIndex(rightOn, joinDF)

    '# JoinCol header search comes after reshape so that Reshape can extract col names
    joinCol = HeaderIndex(joinCol, joinDF)

    '# Header Index Match Array
    joinDF = Sort(joinDF, Array(rightOn))

    Dim i
    For i = LBound(df) + 1 To UBound(df)

        Dim j
        For j = LBound(splitDF) To UBound(splitDF)

            Dim rowPos As Variant
            rowPos = Search_Logic(df(i, leftOn), splitDF(j, 2), rightOn)

            If rowPos <> "<!NO POSITION!>" Then
                If df(i, appendCol) = "" Then
                    df(i, appendCol) = splitDF(j, 2)(rowPos, joinCol)
                Else
                    df(i, appendCol) = df(i, appendCol) & seperator & splitDF(j, 2)(rowPos, joinCol)
                End If
            End If

        Next j

    Next i

    JoinAppend_Logic = df

End Function



'==================================================================================================
'@ Math
'==================================================================================================
Function Math(ByVal df, _
              ByVal colToFill, _
              ByVal mathCols, _
              mathOperation As MathOp)
    
    colToFill = HeaderIndex(colToFill, df)
    mathCols = HeaderIndex(mathCols, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
  
        df(i, colToFill) = df(i, mathCols(0))
        
        Dim j
        For j = LBound(mathCols) + 1 To UBound(mathCols)
            df(i, colToFill) = Math_Logic(df(i, colToFill), df(i, mathCols(j)), mathOperation)
        Next j
        
    Next i

    Math = df
    
End Function


'@ Math_Logic (*Private*)
Private Function Math_Logic(ByVal operand_1, _
                            ByVal operand_2, _
                            mathOperation As MathOp)

    Select Case mathOperation

        Case Is = Add
            Math_Logic = operand_1 + operand_2

        Case Is = subtract
            Math_Logic = operand_1 - operand_2

        Case Is = Multiply
            Math_Logic = operand_1 * operand_2

        Case Is = divide
            If operand_2 <> 0 Then
                Math_Logic = operand_1 / operand_2
            Else
                Math_Logic = 0
            End If

        Case Is = Exponent
            Math_Logic = operand_1 ^ operand_2

        Case Is = Root
            Math_Logic = operand_1 ^ (1 / operand_2)

    End Select

End Function




'==================================================================================================
'@ MoveCol
'==================================================================================================
'# Move selected col to new position

Function MoveCol(ByVal df, _
                 ByVal col, _
                 newPosition As Long)
    
    col = HeaderIndex(col, df)
    MoveCol = MoveCol_Logic(df, col, newPosition)
    
'    Dim i
'
'    If col < newPosition Then
'        For i = col To newPosition - 1
'            df = SwapCols(df, i, i + 1)
'        Next i
'    Else
'        For i = col To newPosition + 1 Step -1
'            df = SwapCols(df, i, i - 1)
'        Next i
'    End If
'
'    MoveCol = df

End Function


Private Function MoveCol_Logic(ByVal df, _
                               ByVal col, _
                               newPosition As Long)
    
    Dim i
    
    If col < newPosition Then
        For i = col To newPosition - 1
            df = SwapCols(df, i, i + 1)
        Next i
    Else
        For i = col To newPosition + 1 Step -1
            df = SwapCols(df, i, i - 1)
        Next i
    End If
       
    MoveCol_Logic = df
    
End Function




'==================================================================================================
'@ Parse
'==================================================================================================
Function Parse(ByVal df, _
               ByVal col, _
               ByVal colToFill, _
               parseBy As ParserOp)
    
    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)

        Dim sourceData As String
        sourceData = df(i, col)

        Dim parsedData As Variant
        parsedData = ""
        
        Dim j
        For j = 1 To Len(sourceData)

            Select Case parseBy

                '#Remove Non Alpha
                Case RemoveNonAlpha
                    Select Case Asc(Mid(sourceData, j, 1))
                        Case 32, 65 To 90, 97 To 122
                            parsedData = parsedData & Mid(sourceData, j, 1)
                    End Select

                '#Removed Non Numeric
                Case RemoveNonNum
                    Select Case Asc(Mid(sourceData, j, 1))
                        Case 48 To 57
                            parsedData = parsedData & Mid(sourceData, j, 1)
                    End Select

                '#Remove Non Alpha Numeric
                Case RemoveNonAphaNum
                    Select Case Asc(Mid(sourceData, j, 1))
                        Case 32, 48 To 57, 65 To 90, 97 To 122
                            parsedData = parsedData & Mid(sourceData, j, 1)
                    End Select

                '#Remove Hyphens
                Case RemoveBlanks
                    If Asc(Mid(sourceData, j, 1)) <> 32 Then
                        parsedData = parsedData & Mid(sourceData, j, 1)
                    End If

                '#Remove Hyphens
                Case RemoveHyphens
                    If Asc(Mid(sourceData, j, 1)) <> 45 Then
                        parsedData = parsedData & Mid(sourceData, j, 1)
                    End If

            End Select

        Next j

        df(i, colToFill) = parsedData

    Next i

    Parse = df

End Function




'==================================================================================================
'@PVal (Present Value)
'==================================================================================================
Function PVal(ByVal df, _
              ByVal sourceCol, _
              ByVal colToFill, _
              ByVal rate As Double, _
              Optional startIndex = 1)
    
    sourceCol = HeaderIndex(sourceCol, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = PV(rate, startIndex + i - 2, 0, df(i, sourceCol)) * -1
    Next i

    PVal = df

End Function



Function PrintColNames(df, Optional delim = "")
    
    Dim colnames
    colnames = ""
    
    Dim i
    For i = LBound(df, 2) To UBound(df, 2)
        If Len(colnames) > 75 Then
            Debug.Print colnames
            colnames = ""
        ElseIf colnames = "" Then
            colnames = df(1, i)
        Else
            colnames = colnames & delim & df(1, i)
        End If
    Next i
    
    Debug.Print colnames
    
End Function

'==================================================================================================
'@Reshape
'==================================================================================================
'# Purpose: Adds/removes columns or rows of given array

Function Reshape(ByVal df, _
                 rowCount, _
                 colcount, _
                 Optional addedColNames)
    
    '# Column Reshape
    Dim originalCount As Long
    originalCount = UBound(df, 2)
    
    ReDim Preserve df(1 To UBound(df), 1 To colcount)
    
    Dim i
'    Dim j
    
    '# Fill Headers
    If IsArray(addedColNames) = True Then
        For i = LBound(addedColNames) To UBound(addedColNames)
            df(1, originalCount + 1 + i) = addedColNames(i)
        Next i
    End If
    
    Reshape = Reshape_Row_Logic(df, rowCount)

'    '# Row Reshape
'    ReDim tempdf(1 To rowCount, 1 To UBound(df, 2))
'
'    Dim upperBound As Long
'    upperBound = rowCount
'
'    If upperBound > UBound(df) Then
'        upperBound = UBound(df)
'    End If
'
'    For i = LBound(df) To upperBound
'        For j = LBound(df, 2) To UBound(df, 2)
'            tempdf(i, j) = df(i, j)
'        Next j
'    Next i

'    Reshape = tempdf

End Function

Private Function Reshape_Row_Logic(ByVal df, ByVal rowCount)


    '# Row Reshape
    ReDim tempdf(1 To rowCount, 1 To UBound(df, 2))
    
    Dim upperBound As Long
    upperBound = rowCount
    
    If upperBound > UBound(df) Then
        upperBound = UBound(df)
    End If
    
    Dim i
    For i = LBound(df) To upperBound
        
        Dim j
        For j = LBound(df, 2) To UBound(df, 2)
            tempdf(i, j) = df(i, j)
        Next j
        
    Next i
    
    Reshape_Row_Logic = tempdf
    
End Function



'==================================================================================================
'@RoundNum
'==================================================================================================

Function RoundNum(ByVal df, _
                  ByVal col, _
                  ByVal colToFill, _
                  Optional digitCount As Long = 0)

    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        If IsNumeric(df(i, col)) Then
            df(i, colToFill) = Round(df(i, col), digitCount)
        End If
    Next i

    RoundNum = df

End Function



'==================================================================================================
'@rowToCol
'==================================================================================================
'# Row becomes a column in a new array

Function RowToCol(df, selectedRow, Optional rowColName = "<ROW1>")
    
    ReDim tempdf(1 To UBound(df, 2) + 1, 1 To 1)
 
    Dim i
    For i = LBound(tempdf) + 1 To UBound(tempdf)
        tempdf(i, 1) = df(selectedRow, i - 1)
    Next i
    
    tempdf(1, 1) = rowColName
    
    RowToCol = tempdf

End Function



'==================================================================================================
'@ ScalarToArray
'==================================================================================================

Private Function ScalarToArray(scalar)
    
    If IsArray(scalar) = False Then
        ScalarToArray = Array(scalar)
    Else
        ScalarToArray = scalar
    End If

End Function




'==================================================================================================
'@ Search
'==================================================================================================
'# Searches a column using binary search algorithm

Function Search(ByVal item, _
                ByVal df, _
                ByVal searchCol)
                       
    searchCol = HeaderIndex(searchCol, df)
    Search = Search_Logic(item, df, searchCol)

End Function


Private Function Search_Logic(ByVal item, _
                              ByVal df, _
                              ByVal searchCol)
                                     
    '# Set foundPos to a false match
    Dim foundPos As Variant
    foundPos = "<!NO POSITION!>"
    
    '# Account for headers in lowerbounds
    Dim low As Long
    low = 2
    
    Dim high As Long
    high = UBound(df)
    
    '# Begin Loop
    Do While (low <= high)

        Dim midpointIndex As Long
        midpointIndex = (high + low) \ 2

        Dim midpointNum As Variant
        midpointNum = df(midpointIndex, searchCol)
        
        If item > midpointNum Then
             low = midpointIndex + 1
         ElseIf item < midpointNum Then
            high = midpointIndex - 1
        Else
            foundPos = midpointIndex
            Exit Do
        End If

    Loop

    Search_Logic = foundPos
                                                    
End Function




'==================================================================================================
'@ SelectCols
'==================================================================================================
'# Selects columns you want to keep

Function SelectCols(ByVal df, ByVal cols)
    
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)
    
    ReDim tempdf(1 To UBound(df), 1 To UBound(cols) + 1)
    
    Dim i
    For i = LBound(cols) To UBound(cols)
        
        Dim j
        For j = LBound(tempdf) To UBound(tempdf)
            tempdf(j, i + 1) = df(j, cols(i))
        Next j
        
    Next i
      
    SelectCols = tempdf

End Function




'==================================================================================================
'@SelectLeft
'==================================================================================================
Function SelectLeft(ByVal df, _
                    ByVal col, _
                    ByVal colToFill, _
                    charCount As Long)

    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)

    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = left(df(i, col), charCount)
    Next i

    SelectLeft = df

End Function




'==================================================================================================
'@SelectMid
'==================================================================================================
Function SelectMid(ByVal df, _
                   ByVal col, _
                   ByVal colToFill, _
                   start, _
                   charCount As Long)

    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)

    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = Mid(df(i, col), start, charCount)
    Next i

    SelectMid = df

End Function




'==================================================================================================
'@SelectRight
'==================================================================================================
Function SelectRight(ByVal df, _
                     ByVal col, _
                     ByVal colToFill, _
                     charCount As Long)

    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)

    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = Right(df(i, col), charCount)
    Next i

    SelectRight = df

End Function




'==================================================================================================
'@SeqDF
'==================================================================================================
'# Purpose: Creates a single column DF that is a sequence of numbers in the column

Function SeqDF(startNumber, _
                numberCount, _
                Optional step = 1, _
                Optional headerName = "<Header1>")

    ReDim tempdf(1 To numberCount + 1, 1 To 1)

    Dim i As Long
    For i = LBound(tempdf) + 1 To UBound(tempdf)
        tempdf(i, 1) = startNumber + (i - 2) * step
    Next i

    '# Fill in headers
    tempdf(1, 1) = headerName

    SeqDF = tempdf

End Function




'==================================================================================================
'@ SetBounds
'==================================================================================================
'# Sets numbers in a column to a min and max if they are lower or greater

Function SetBounds(ByVal df, _
                   ByVal col, _
                   ByVal colToFill, _
                   Optional max = 0, _
                   Optional min = 0)
                           
    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        
        df(i, colToFill) = df(i, col)
    
        If df(i, col) > max Then
            df(i, colToFill) = max
        End If

        If df(i, col) < min Then
            df(i, colToFill) = min
        End If

    Next i
    
    SetBounds = df

End Function


'==================================================================================================
'@sort
'==================================================================================================

Function Sort(ByVal df, _
              ByVal sortCols, _
              Optional ascending As Boolean = True)
    
    sortCols = ScalarToArray(sortCols)
    sortCols = HeaderIndex(sortCols, df)
    
    '# Add concatenate column
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
    
    '# Concatenate sort columns
    df = Concat(df, UBound(df, 2), sortCols, "/-/")

    '# Sort Array
    If UBound(df) > 1 Then
        
        Sort_Logic df, UBound(df, 2), LBound(df) + 1, UBound(df)
        
        '# Ascending
        If ascending = False Then
            df = Flip(df)
        End If
    
    End If
    
    '# Remove concatenated column
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) - 1)
    
    Sort = df
    
End Function


Private Function Sort_Logic(df, _
                            sortOnCol As Long, _
                            lowerBounds As Long, _
                            UpperBOunds As Long)
       
    Dim pivot As Variant
    pivot = df((lowerBounds + UpperBOunds) \ 2, sortOnCol)
    
    '# Lower Index and Num
    Dim lowerIndex As Long
    lowerIndex = lowerBounds
    
    Dim lowerNum As Variant
    lowerNum = df(lowerIndex, sortOnCol)
    
    '# Upper Index and Num
    Dim upperIndex As Long
    upperIndex = UpperBOunds
    
    Dim upperNum As Variant
    upperNum = df(upperIndex, sortOnCol)
        
    '# Sort
    Do While (lowerIndex <= upperIndex)
    
        '# Lower partition
        Do While lowerNum < pivot
            lowerIndex = lowerIndex + 1
            lowerNum = df(lowerIndex, sortOnCol)
        Loop
        
        '# upper partition
        Do While upperNum > pivot
            upperIndex = upperIndex - 1
            upperNum = df(upperIndex, sortOnCol)
        Loop
        
        '# Swap Data
        If (lowerIndex <= upperIndex) Then
        
            Dim i As Long
            Dim tempItem As Variant
    
            For i = LBound(df, 2) To UBound(df, 2)
                tempItem = df(lowerIndex, i)
                df(lowerIndex, i) = df(upperIndex, i)
                df(upperIndex, i) = tempItem
            Next i
            
            lowerIndex = lowerIndex + 1
            upperIndex = upperIndex - 1
            
            If upperIndex = 0 Then
                upperIndex = 1
            End If
            
            If lowerIndex > UBound(df) Then
                lowerIndex = lowerIndex - 1
            End If
            
        End If
        
        '# Update lowerNum and upperNum
        lowerNum = df(lowerIndex, sortOnCol)
        upperNum = df(upperIndex, sortOnCol)
                   
    Loop

    '# Recursive Element
    If (lowerBounds < upperIndex) Then
        Sort_Logic df, sortOnCol, lowerBounds, upperIndex
    End If
    
    If (lowerIndex < UpperBOunds) Then
        Sort_Logic df, sortOnCol, lowerIndex, UpperBOunds
    End If
   
End Function


'==================================================================================================
'@splitData
'==================================================================================================
'# Purpose: Splits data in a column into seperate columns
'#
'# Required: headerIndex, concat, uniqueArray, binarySearch, MoveCol
'#
'# Dependents: group
'#
'# Notes:
'#
'# Example:
'#
Function SplitData(ByVal df, _
                   ByVal col, _
                   ByVal colsToFill, _
                   delimiter, _
                   Optional skipHead = True)
    
    col = HeaderIndex(col, df)
    
    colsToFill = ScalarToArray(colsToFill)
    colsToFill = HeaderIndex(colsToFill, df)
    
    Dim i
    For i = LBound(df) + Abs(skipHead) To UBound(df)

        If InStr(1, df(i, col), delimiter) > 0 And IsMissing(delimiter) = False Then

            Dim tempdf As Variant
            tempdf = Split(df(i, col), delimiter)

            If UBound(tempdf) = UBound(colsToFill) Then
                
                Dim j
                For j = LBound(colsToFill) To UBound(colsToFill)
                    df(i, colsToFill(j)) = tempdf(j)
                Next j
                
            Else
                df(i, colsToFill(0)) = "<!SPLIT ERROR!>"
            End If

        End If

    Next i

    '# Return
    SplitData = df

End Function


'==================================================================================================
'@SplitOnCol
'==================================================================================================
'# Split DF into multiple DFs base off the category column supplied. Category is
'# filled in first column and the filtered DF is in the second column.

Function SplitOnCol(ByVal df, ByVal categoryCols)
  
    categoryCols = ScalarToArray(categoryCols)
    categoryCols = HeaderIndex(categoryCols, df)
    
    '# Add concatenate column
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
    
    '# Concatenate sort columns
    df = Concat(df, UBound(df, 2), categoryCols, "|")
    
    '# Sort df because we are using Filter_Fast
    Sort_Logic df, UBound(df, 2), LBound(df) + 1, UBound(df)
    
    Dim tempNamedf
    tempNamedf = Unique(df, UBound(df, 2))

    ReDim tempdf(1 To UBound(tempNamedf) - 1, 1 To 2)
    

    Dim i
    For i = LBound(tempNamedf) + 1 To UBound(tempNamedf)
        tempdf(i - 1, 1) = tempNamedf(i, 1)
        tempdf(i - 1, 2) = Filter_Fast(df, tempNamedf(i, 1), UBound(df, 2))
        tempdf(i - 1, 2) = DropCol_Logic(tempdf(i - 1, 2), Array(UBound(tempdf(i - 1, 2), 2)))
    Next i

    SplitOnCol = tempdf
    
End Function


'==================================================================================================
'@Stack
'==================================================================================================
Function Stack(ByVal df1, ByVal df2)

    If IsEmpty(df1) Then
        Stack = df2
    Else
        Stack = Stack_Logic(df1, df2)
    End If

End Function


Private Function Stack_Logic(ByVal df1, ByVal df2)

    Dim origRows
    origRows = UBound(df1)

    df1 = Reshape(df1, UBound(df1) + UBound(df2) - 1, UBound(df2, 2))

    If UBound(df1, 2) = UBound(df2, 2) Then

        Dim i
        Dim j
        For i = LBound(df2) + 1 To UBound(df2)
            For j = LBound(df1, 2) To UBound(df1, 2)
                df1(i + origRows - 1, j) = df2(i, j)
            Next j
        Next i

    Else
        Debug.Print "<!WARNING!> Arrays do not have same column count"
    End If

    Stack_Logic = df1
    
End Function


'==================================================================================================
'@StackFromPaths
'==================================================================================================
Function StackFromPaths(ByVal fileDataDf, Optional sourceColName = "Source")

    Dim i
    For i = LBound(fileDataDf) + 1 To UBound(fileDataDf)
        
        Dim path
        path = GetElement(fileDataDf, "Path", i)
        
        Dim tempdf
        tempdf = GetData(path)

        tempdf = AddCols(tempdf, sourceColName)
        tempdf = FillCol(tempdf, sourceColName, GetElement(fileDataDf, "Name", i))

        Dim finalDf
        finalDf = Stack(finalDf, tempdf)
        
    Next i
    
    StackFromPaths = finalDf
    
End Function


'==================================================================================================
'@StrLow
'==================================================================================================
Function StrLow(ByVal df, ByVal col)

    col = HeaderIndex(col, df)

    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, col) = LCase(df(i, col))
    Next i

    StrLow = df

End Function




'==================================================================================================
'@StrUp
'==================================================================================================
Function StrUp(ByVal df, ByVal col)

    col = HeaderIndex(col, df)

    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, col) = UCase(df(i, col))
    Next i

    StrUp = df

End Function




'==================================================================================================
'@ SumCols
'==================================================================================================
'# Sums selected columns

Function SumCols(ByVal df, ByVal cols)
    
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)
    
    SumCols = SumCols_Logic

'    Dim total As Double
'
'    Dim i
'    For i = LBound(df) + 1 To UBound(df)
'
'        Dim j
'        For j = LBound(cols) To UBound(cols)
'            If IsNumeric(df(i, cols(j))) = True Then
'                total = total + df(i, cols(j))
'            End If
'        Next j
'
'    Next i
'
'    SumCols = total

End Function

Private Function SumCols_Logic(ByVal df, ByVal cols)
    
    Dim total As Double
    total = 0
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        Dim j
        For j = LBound(cols) To UBound(cols)
            If IsNumeric(df(i, cols(j))) = True Then
                total = total + df(i, cols(j))
            End If
        Next j
        
    Next i
    
   SumCols_Logic = total

End Function


'==================================================================================================
'@ SumIf
'==================================================================================================
Function SumIf(ByVal df, _
               ByVal criteria, _
               ByVal searchCol, _
               ByVal sumCol, _
               compareby As ComparerOp, _
               Optional limit)

    searchCol = HeaderIndex(searchCol, df)
    sumCol = HeaderIndex(sumCol, df)

    Dim total As Double

    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby, limit)

        If outcome = True Then
            total = total + df(i, sumCol)
        End If

    Next i

    SumIf = total

End Function




'==================================================================================================
'@ SwapCols
'==================================================================================================
'# Swaps two selected columns.

Function SwapCols(ByVal df, _
                  ByVal col1, _
                  ByVal col2)

    col1 = HeaderIndex(col1, df)
    col2 = HeaderIndex(col2, df)
    
    Dim i
    For i = LBound(df) To UBound(df)
        Dim tempVar As Variant
        tempVar = df(i, col1)
        df(i, col1) = df(i, col2)
        df(i, col2) = tempVar
    Next i

    SwapCols = df

End Function




'==================================================================================================
'@Transpose
'==================================================================================================
Function Transpose(ByVal df)

    ReDim tempdf(LBound(df, 2) To UBound(df, 2), LBound(df) To UBound(df))
    
    Dim i
    For i = LBound(df) To UBound(df)
    
        Dim j
        For j = LBound(df, 2) To UBound(df, 2)
            tempdf(j, i) = df(i, j)
        Next j
        
    Next i

    Transpose = tempdf

End Function



'==================================================================================================
'@TrimData
'==================================================================================================
Function TrimData(ByVal df, ByVal col)

    col = HeaderIndex(col, df)

    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, col) = Trim(df(i, col))
    Next i

    TrimData = df

End Function



'==================================================================================================
'@ Unique
'==================================================================================================
'# Filters on supplied column(s) to unique elements

Function Unique(ByVal df, ByVal cols)
    
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)

    If UBound(df) > 1 Then
        df = Unique_Logic(df, cols)
    Else
        ReDim tempdf(1 To 1, 1 To UBound(cols) + 1)
        
        Dim i
        For i = LBound(cols) To UBound(cols)
            tempdf(1, i + 1) = df(1, cols(i))
        Next i

        df = tempdf
    End If

    Unique = df
        
End Function


Private Function Unique_Logic(ByVal df, ByVal cols)
    
    cols = HeaderIndex(cols, df)

    df = Concat(df, cols(0), cols, "/--/", False)
    df = SelectCols(df, Array(cols(0)))

    df = Sort(df, Array(1), True)

    ReDim tempdf(1 To UBound(df), 1 To 1) As Variant

    '# Assign Headers
    tempdf(1, 1) = df(1, 1)

    '# Assign first Row
    tempdf(2, 1) = df(2, 1)

    Dim rowIncr
    rowIncr = 2

    Dim nextRowIncr
    nextRowIncr = 1

    Dim tempIncr
    tempIncr = 2

    '# Search For Unique then Fill Array
    Do While (rowIncr + nextRowIncr) <= UBound(df)

        Dim nextRow As Variant
        nextRow = df(rowIncr + nextRowIncr, 1)

        If df(rowIncr, 1) = nextRow Then
            nextRowIncr = nextRowIncr + 1
        Else
            tempIncr = tempIncr + 1
            tempdf(tempIncr, 1) = nextRow
            rowIncr = rowIncr + nextRowIncr
            nextRowIncr = 1
        End If
    Loop

    '# Assing Temp Array to Final Array
    tempdf = Reshape(tempdf, tempIncr, UBound(cols) + 1)

    If UBound(cols) > 0 Then
        tempdf = SplitData(tempdf, 1, Arrange(1, UBound(cols) + 1), "/--/", False)
    End If

    Unique_Logic = tempdf

End Function
