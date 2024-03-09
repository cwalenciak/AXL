VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "helix"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const NO_POSITION_ERR = "<!NO POSITION!>"
Private Const SPLIT_ERR = "<!SPLIT ERROR!>"
Private Const TEMP_COLUMN = "<!TEMP COL!>"
Private Const JUNK_STR = "<!JUNK STR!>"
Private Const JUNK_STR_LEN = 12
Private Const INTERNAL_SEP = "<||>"


Enum CastType
    IntegerType
    LongType
    DoubleType
    stringType
    DateType
End Enum


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


Enum AggragatorOp
    countAggr
    sumAggr
    meanAggr
    medianAggr
    maxAggr
    minAggr
    sdevAggr
    sdevpAggr
End Enum


Enum KeepType
    First
    last
    all
End Enum




Function AbsVal(ByVal df, ByVal cols)
    
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        
        Dim col
        For Each col In cols
            df(i, col) = Abs(df(i, col))
        Next col
        
    Next i

    AbsVal = df
    
End Function



Function AddCols(ByVal df, ByVal ColNames)

    ColNames = ScalarToArray(ColNames)
    
    Dim originalCount
    originalCount = UBound(df, 2)
    
    ReDim Preserve df( _
        1 To UBound(df), _
        1 To UBound(df, 2) + UBound(ColNames) + 1 _
    )
        
    Dim i
    If IsArray(ColNames) = True Then
        For i = LBound(ColNames) To UBound(ColNames)
            df(1, originalCount + 1 + i) = ColNames(i)
        Next i
    End If

    AddCols = df
        
End Function



Function AddGroupIndex2(ByVal df, ByVal groupCols)
    
    groupCols = ScalarToArray(groupCols)
    groupCols = HeaderIndex(groupCols, df)
    
    ReDim Preserve df( _
        1 To UBound(df), _
        1 To UBound(df, 2) + 1 _
    )
    
    df(1, UBound(df, 2)) = "GROUP_INDEX"
    
    Dim incr
    incr = 1
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        Debug.Print df(i, 1)
        If incr = 1 Then
            df(i, UBound(df, 2)) = incr
            incr = incr + 1
        Else
            
            Dim outcome
            outcome = True
            
            Dim elem
            For Each elem In groupCols
                
                If df(i, elem) <> df(i - 1, elem) Then
                    outcome = False
                    Exit For
                End If
            
            Next elem
            
            If outcome Then
                df(i, UBound(df, 2)) = incr
                incr = incr + 1
            Else
                incr = 1
                df(i, UBound(df, 2)) = incr
            End If
        
        End If
        
    Next i
    
    AddGroupIndex2 = df
    
End Function


Function AddGroupIndex(ByVal df, ByVal groupCols)
    
    groupCols = ScalarToArray(groupCols)
    groupCols = HeaderIndex(groupCols, df)
    
    ReDim Preserve df( _
        1 To UBound(df), _
        1 To UBound(df, 2) + 1 _
    )
    
    df(1, UBound(df, 2)) = "GROUP_INDEX"
    
    Dim incr
    incr = 1
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)

        Dim outcome
        outcome = True
        
        Dim elem
        For Each elem In groupCols
            
            If df(i, elem) <> df(i - 1, elem) Then
                outcome = False
                Exit For
            End If
        
        Next elem
        
        
        If outcome Then
            incr = incr + 1
            df(i, UBound(df, 2)) = incr
        Else
            incr = 1
            df(i, UBound(df, 2)) = incr
        End If

        
    Next i
    
    AddGroupIndex = df
    
End Function




Function AddIndex(ByVal df, _
                  Optional indexName As String = "<INDEX>", _
                  Optional posOne As Boolean = True)

    ReDim Preserve df( _
        1 To UBound(df), _
        1 To UBound(df, 2) + 1 _
    )
    
    df(1, UBound(df, 2)) = indexName
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, UBound(df, 2)) = i - 1
    Next i
    
    If posOne Then
        MoveCol_Logic df, indexName, 1
    End If
    
    AddIndex = df

End Function



Function AddQuarterCol(ByVal df, _
                       ByVal monthCol, _
                       Optional colName = "Qtr", _
                       Optional prefix = "Q")

    df = AddCols(df, colName)
    
    monthCol = HeaderIndex(monthCol, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        Select Case LCase(df(i, monthCol))
        
            Case "january", "jan", "february", "feb", "march", "mar"
                df(i, UBound(df, 2)) = prefix & "1"
                
            Case "april", "apr", "may", "june", "jun"
                df(i, UBound(df, 2)) = prefix & "2"
                
            Case "july", "jul", "august", "aug", "september", "sep"
                df(i, UBound(df, 2)) = prefix & "3"
                
            Case "october", "oct", "november", "nov", "december", "dec"
                df(i, UBound(df, 2)) = prefix & "4"
        
        End Select
    
    Next i
                       
    AddQuarterCol = df

End Function



Function AddTotalCol(ByVal df, _
                     ByVal numCols, _
                     Optional colName = "Total")

    numCols = ScalarToArray(numCols)
    numCols = HeaderIndex(numCols, df)
     
    ReDim Preserve df( _
        1 To UBound(df), _
        1 To UBound(df, 2) + 1 _
    )
    
    df(1, UBound(df, 2)) = colName
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        Dim total As Double
        total = 0
        
        Dim j
        For j = LBound(numCols) To UBound(numCols)
            If IsNumeric(df(i, numCols(j))) = True Then
                total = total + df(i, numCols(j))
            End If
        Next j
        
        df(i, UBound(df, 2)) = total
    
    Next i
    

    AddTotalCol = df
    
End Function



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



Function Arrange(startNumber, numberCount, Optional Step = 1)
       
    ReDim arr(0 To numberCount - 1)
    
    Dim i
    For i = LBound(arr) To UBound(arr)
        arr(i) = startNumber + i * Step
    Next i
    
    Arrange = arr

End Function



Function ArrayAppend(ByVal arr, items)

    items = ScalarToArray(items)
    
    Dim originalDim
    originalDim = UBound(arr)
    
    ReDim Preserve arr(0 To UBound(arr) + UBound(items) + 1)
    
    Dim i
    For i = LBound(items) To UBound(items)
        arr(i + 1 + originalDim) = items(i)
    Next i
    
    ArrayAppend = arr
    
End Function



Function ArrayAppendElem(ByVal arr, _
                         item, _
                         Optional infront = False)

    Dim i

    If infront Then
        For i = LBound(arr) To UBound(arr)
            arr(i) = item & arr(i)
        Next i
    Else
        For i = LBound(arr) To UBound(arr)
            arr(i) = arr(i) & item
        Next i
    End If

    ArrayAppendElem = arr
    
End Function



Function ArrayCombine(ByVal arr1, ByVal arr2)

    ReDim temparr(0 + UBound(arr1) + UBound(arr2) + 1)
    
    Dim i
    For i = LBound(arr1) To UBound(arr1)
        temparr(i) = arr1(i)
    Next i
    
    
    For i = LBound(arr2) To UBound(arr2)
        temparr(1 + UBound(arr1) + i) = arr2(i)
    Next i
    
    ArrayCombine = temparr

End Function


Function ArrayDrop(ByVal arr, index)
    
    If UBound(arr) > 0 Then
        ReDim temparr(0 To UBound(arr) - 1)
        
        Dim incr
        incr = 0
        
        Dim i
        For i = LBound(arr) To UBound(arr)
            If i <> index Then
                temparr(incr) = arr(i)
                incr = incr + 1
            End If
        Next i
        
        ArrayDrop = temparr
    
    Else
        ArrayDrop = Empty
    End If
    
End Function



Function ArrayPrint(ByVal arr)
    
    Dim elem
    For Each elem In arr
        Debug.Print elem
    Next elem
    
End Function



Function ArrayReplace(arr, findElem, replaceElem)

    Dim i
    For i = LBound(arr) To UBound(arr)
        arr(i) = Replace(arr(i), findElem, replaceElem)
    Next i
    
    ArrayReplace = arr
    
End Function



Function CalculateSlope(ByVal df, xcol, ycol)

    Dim xy
    xy = "xy"
    
    Dim x2
    x2 = "x2"

    df = AddCols(df, Array(xy, x2))
    
    df = Math(df, xy, Array(xcol, ycol), Multiply)
    df = Math(df, x2, Array(xcol), Exponent, 2)
    
    Dim xSum
    xSum = SumCols(df, xcol)
    
    Dim ySum
    ySum = SumCols(df, ycol)
    
    Dim xySum
    xySum = SumCols(df, xy)
    
    Dim nxySum
    nxySum = xySum * (UBound(df) - 1)
    
    Dim nx2sum
    nx2sum = SumCols(df, x2) * (UBound(df) - 1)
    
    Dim xSum2
    xSum2 = xSum * xSum
    
    Dim numerator
    numerator = nxySum - (xSum * ySum)
    
    Dim denominator
    denominator = nx2sum - xSum2
    
    CalculateSlope = numerator / denominator

End Function



Function CastTo(ByVal df, col, typeToCast As CastType)

    col = HeaderIndex(col, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        Select Case typeToCast
        
            Case IntegerType
                df(i, col) = CInt(df(i, col))
                
            Case LongType
                df(i, col) = CLng(df(i, col))
            
            Case DoubleType
                df(i, col) = CDbl(df(i, col))
                
            Case stringType
                df(i, col) = CStr(df(i, col))
                
            Case DateType
                df(i, col) = CDate(df(i, col))
        
        End Select
        
    Next i
    
    CastTo = df

End Function



Function ChangeCell(ByVal df, _
                    ByVal col, _
                    ByVal row, _
                    item)

    col = HeaderIndex(col, df)
    
    df(row, col) = item
    
    ChangeCell = df

End Function



Function ChangeQty(ByVal df, _
                   valueCol, _
                   Optional groupCol, _
                   Optional percChg = False, _
                   Optional name = "Chg")

    '------------------------------------------------------
    '# Description:
    '# Calculate the change of a column by shifting the
    '# data down and getting the difference
    '------------------------------------------------------
    
    df = ShiftDown(df, valueCol, groupCol, name)
    
    valueCol = HeaderIndex(valueCol, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        If df(i, UBound(df, 2)) <> "" Then
            
            df(i, UBound(df, 2)) = df(i, valueCol) - df(i, UBound(df, 2))
            
            If percChg And df(i, UBound(df, 2) - 1) <> 0 Then
                df(i, UBound(df, 2)) = df(i, UBound(df, 2)) / df(i - 1, valueCol)
            End If
            
        End If
        
    Next i
    
    ChangeQty = df

End Function


Function ColMean(ByVal df, col)
    
    col = HeaderIndex(col, df)
    
    ColMean = ColMean_Logic(df, col)
    
End Function


Function ColMean_Logic(ByVal df, col)

    Dim iSum
    Dim iCount
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        If IsNumeric(df(i, col)) Then
            iSum = iSum + df(i, col)
            iCount = iCount + 1
        End If
    Next
    
    If iCount > 0 Then
        ColMean_Logic = iSum / iCount
    Else
        ColMean_Logic = "<!ERROR!>: Count is 0"
    End If

End Function



Function ColToArray(df, col, Optional numericArr = False)
    
    col = HeaderIndex(col, df)
    
    ReDim arr(1 To UBound(df) - 1)
    
    Dim i
    For i = LBound(df) To UBound(df) - 1
        If Not numericArr Then
            arr(i) = df(i + 1, col)
        Else
            If df(i + 1, col) = "" Then
                arr(i) = 0
            Else
                arr(i) = df(i + 1, col)
            End If
        End If
    Next i
    
    ColToArray = arr
    
End Function



Sub ColToCmbx(ByVal df, _
              col, _
              ByVal cmbx As ComboBox, _
              Optional displayItemOne As Boolean = True, _
              Optional excludeFirstRow As Boolean = True)

    cmbx.Clear
    
    col = HeaderIndex(col, df)
    
    Dim i As Long
    For i = LBound(df) + Abs(excludeFirstRow) To UBound(df)
        cmbx.AddItem df(i, col)
    Next i
              
    If displayItemOne = True Then
        cmbx.value = df(LBound(df) + Abs(excludeFirstRow), col)
    End If
    
End Sub



Private Function Compare(ByVal item1, ByVal item2, compareby As ComparerOp) As Boolean

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



Function CompareColsFill(ByVal df, _
                         ByVal colToFill, _
                         ByVal compareCol1, _
                         ByVal compareCol2, _
                         compareby As ComparerOp, _
                         trueReturn, _
                         Optional falseReturn = "")

    colToFill = HeaderIndex(colToFill, df)
    compareCol1 = HeaderIndex(compareCol1, df)
    compareCol2 = HeaderIndex(compareCol2, df)
    
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
    
        Dim outcome As Boolean
        outcome = Compare(df(i, compareCol1), df(i, compareCol2), compareby)
        
        If outcome = True Then
            df(i, colToFill) = trueReturn
        Else
            df(i, colToFill) = falseReturn
        End If
        
    Next i
    
    CompareColsFill = df

End Function



Function CompareColsReturn(ByVal df, _
                           ByVal colToFill, _
                           ByVal compareCol1, _
                           ByVal compareCol2, _
                           compareby As ComparerOp, _
                           trueCol, _
                           Optional falseCol)
    
    '------------------------------------------------------
    '# Description:
    '# Compares two columns and then fills a column with a
    '# true column element.
    '------------------------------------------------------
    
    colToFill = HeaderIndex(colToFill, df)
    compareCol1 = HeaderIndex(compareCol1, df)
    compareCol2 = HeaderIndex(compareCol2, df)
    trueCol = HeaderIndex(trueCol, df)
    
    If Not IsMissing(falseCol) Then
        falseCol = HeaderIndex(falseCol, df)
    End If
    
    
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
    
        Dim outcome As Boolean
        outcome = Compare(df(i, compareCol1), df(i, compareCol2), compareby)
        
        If outcome = True Then
            df(i, colToFill) = df(i, trueCol)
        End If
        
        If Not outcome And Not IsMissing(falseCol) Then
            df(i, colToFill) = df(i, falseCol)
        End If
        
    Next i
    
    CompareColsReturn = df

End Function



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



Function CopyCol(ByVal df, ByVal colToFill, ByVal colToCopy)
    
    colToFill = HeaderIndex(colToFill, df)
    colToCopy = HeaderIndex(colToCopy, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = df(i, colToCopy)
    Next i
    
    CopyCol = df

End Function



Function CopyColIf(ByVal df, _
                   ByVal colToFill, _
                   ByVal colToCopy, _
                   criteria, _
                   ByVal searchCol, _
                   compareby As ComparerOp)

    colToFill = HeaderIndex(colToFill, df)
    colToCopy = HeaderIndex(colToCopy, df)
    searchCol = HeaderIndex(searchCol, df)
    
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
    
        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby)
                                
        If outcome = True Then
            df(i, colToFill) = df(i, colToCopy)
        End If
        
    Next i
    
    CopyColIf = df
    
End Function



Function CountIf(ByVal df, _
                 ByVal criteria, _
                 ByVal searchCol, _
                 compareby As ComparerOp)

    searchCol = HeaderIndex(searchCol, df)

    Dim total As Double
    
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
        
        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby)
        
        If outcome = True Then
            total = total + 1
        End If
        
    Next i
    
    CountIf = total

End Function



Function CrossJoinArr(ByVal df, arr, Optional newCOl = "arr")

    Dim rowCount
    rowCount = (UBound(arr) + 1) * (UBound(df) - 1)
    
    ReDim tempdf(1 To rowCount + 1, 1 To UBound(df, 2) + 1)
    
    Dim i
    For i = LBound(df, 2) To UBound(df, 2)
        tempdf(1, i) = df(1, i)
    Next i
    
    tempdf(1, UBound(tempdf, 2)) = newCOl
    
    For i = LBound(df) + 1 To UBound(df)
    
        Dim j
        For j = LBound(arr) To UBound(arr)
            
            Dim k
            For k = LBound(df, 2) To UBound(df, 2)
                tempdf(pos, UBound(tempdf, 2)) = arr(j)
                tempdf(pos, k) = df(i, k)
            Next k
        
        Next j
    
    Next i

    CrossJoinArr = tempdf

End Function



Function DateDF(startDate As Date, _
                dayCount, _
                Optional Step = 1, _
                Optional headerName = "Date")

    ReDim tempdf(1 To dayCount + 1, 1 To 1)

    Dim i As Long
    For i = LBound(tempdf) + 1 To UBound(tempdf)
        tempdf(i, 1) = startDate + (i - 2) * Step
    Next i

    '# Fill in headers
    tempdf(1, 1) = headerName

    DateDF = tempdf

End Function



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



Function DropCol(ByVal df, ByVal cols)
    
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)
    
    Dim col
    For Each col In cols
        df = ChangeCell(df, col, 1, "<!DELETE!>")
    Next col
    
    df = FilterCols(df, "<!DELETE!>", NotEqual)
    
    DropCol = df
    
End Function



Function DropRows(ByVal df, rowNums)
    
    df = AddIndex(df)
    
    Dim row
    For Each row In rowNums
        df(row + 1, UBound(df, 2)) = UBound(df) + 10
    Next row
    
    df = Sort(df, "<INDEX>")
    df = Reshape(df, UBound(df) - UBound(rowNums) - 1, UBound(df, 2) - 1)
    
    DropwRows = df

End Function



Function Duplicated(ByVal df, _
                    cols, _
                    Optional keep As KeepType = all, _
                    Optional colName = "Duplicated", _
                    Optional dupePosition = False)

    cols = HeaderIndex(cols, df)
    cols = ScalarToArray(cols)
    
    ReDim Preserve df( _
        1 To UBound(df), _
        1 To UBound(df, 2) + 4 _
    )
    
    Dim dupeCol As Long
    dupeCol = UBound(df, 2)
    
    Dim firstLastCol As Long
    firstLastCol = UBound(df, 2) - 1
    
    Dim indexCol As Long
    indexCol = UBound(df, 2) - 2
    
    Dim fillDupeCol As Long
    fillDupeCol = UBound(df, 2) - 3
    
    df = fillCol(df, dupeCol, cols)
    Export df
    Sort_Logic _
        df:=df, _
        sortOnCol:=UBound(df, 2), _
        lowerBounds:=LBound(df) + 1, _
        UpperBounds:=UBound(df)
        
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
        
        If i < UBound(df) Then
            
            If df(i, dupeCol) = df(i + 1, dupeCol) _
                And df(i, dupeCol) <> df(i - 1, dupeCol) Then
                
                df(i, indexCol) = 1
                df(i, fillDupeCol) = True
                df(i, firstLastCol) = "first"
            
            ElseIf df(i, dupeCol) <> df(i + 1, dupeCol) _
                And df(i, dupeCol) = df(i - 1, dupeCol) Then
                
                df(i, indexCol) = df(i - 1, indexCol) + 1
                df(i, fillDupeCol) = True
                df(i, firstLastCol) = "last"
                
            ElseIf df(i, dupeCol) = df(i + 1, dupeCol) _
                And df(i, dupeCol) = df(i - 1, dupeCol) Then
                
                df(i, indexCol) = df(i - 1, indexCol) + 1
                df(i, fillDupeCol) = True
                df(i, firstLastCol) = "middle"
            End If
            
        Else
        
            If df(i, dupeCol) = df(i - 1, dupeCol) Then
                df(i, fillDupeCol) = True
                df(i, indexCol) = df(i - 1, indexCol) + 1
                df(i, fillDupeCol) = True
                df(i, firstLastCol) = "last"
            End If
        
        End If
    
    Next i
    
    
    If keep <> all Then
        df = Filter_Logic(df, "middle", firstLastCol, NotEqual)
    End If
    
    
    If keep = First Then
        df = Filter_Logic(df, "last", firstLastCol, NotEqual)
    ElseIf keep = last Then
        df = Filter_Logic(df, "first", firstLastCol, NotEqual)
    End If
    
        
    If dupePosition Then
        ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) - 2)
    Else
        ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) - 3)
    End If
    
    
    Duplicated = df

End Function



Sub Export(ByVal df, _
           Optional wb As Workbook, _
           Optional ws As Worksheet, _
           Optional startRow = 1, _
           Optional StartCol = 1)

            
    If wb Is Nothing Then
        Set wb = Workbooks.Add
    End If
            
    If ws Is Nothing Then
        Set ws = ActiveSheet
    End If
    
    Dim endRow As Long
    endRow = startRow + UBound(df) - 1
    
    Dim endColumn As Long
    endColumn = StartCol + UBound(df, 2) - 1
    
    Dim exportRange As Range
    Set exportRange = ws.Range(ws.Cells(startRow, StartCol), ws.Cells(endRow, endColumn))
             
    exportRange = df
    
End Sub



Function ElemLen(ByVal df, col, colToFill)

    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = Len(df(i, col))
    Next i
    
    ElemLen = df

End Function



Function FileData(filesFldrPath)

    Dim fso As FileSystemObject
    Set fso = New FileSystemObject
    
    Dim fldr As Folder
    Set fldr = fso.GetFolder(filesFldrPath)
    
    If fldr.Files.Count > 0 Then
    
        ReDim df(1 To fldr.Files.Count + 1, 1 To 3)
    
        df(1, 1) = "Path"
        df(1, 2) = "Name"
        df(1, 3) = "Extension"
    
        Dim i As Long
        i = 2
        
        Dim file As file
        For Each file In fldr.Files
            
            Dim extStart
            extStart = InStrRev(file.name, ".")
            
            df(i, 1) = file.path
            df(i, 2) = Left(file.name, extStart - 1)
            df(i, 3) = Right(file.name, Len(file.name) - extStart)
        
            i = i + 1
        
        Next file
        
    Else
        ReDim df(1 To 1, 1 To 3)
    End If
    
    FileData = df
    
End Function



Function fillCol(ByVal df, ByVal colToFill, item, Optional skipHeader = True)

    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + Abs(skipHeader) To UBound(df)
        df(i, colToFill) = item
    Next i

    fillCol = df

End Function



Function fillColIf(ByVal df, _
                   ByVal colToFill, _
                   criteria, _
                   ByVal searchCol, _
                   compareby As ComparerOp, _
                   trueReturn, _
                   Optional falseReturn = "", _
                   Optional noFalseReturn = False)

    colToFill = HeaderIndex(colToFill, df)
    searchCol = HeaderIndex(searchCol, df)
    
    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
    
        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby)
        
        If outcome = True Then
            df(i, colToFill) = trueReturn
        Else
            If Not noFalseReturn Then
                df(i, colToFill) = falseReturn
            End If
        End If
        
    Next i
   
    fillColIf = df

End Function




Function FillDown(ByVal df, col, Optional groupCol)

    col = HeaderIndex(col, df)
    
    If Not IsMissing(groupCol) Then
        groupCol = HeaderIndex(groupCol, df)
    End If
    
    Dim i
    For i = LBound(df) + 2 To UBound(df)
        
        If IsMissing(groupCol) Then
        
            If df(i, col) = "" Then
                df(i, col) = df(i - 1, col)
            End If
            
        Else
        
            If df(i, col) = "" And df(i, groupCol) = df(i - 1, groupCol) Then
                df(i, col) = df(i - 1, col)
            End If
            
        End If
    
    Next i
    
    FillDown = df

End Function



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



Function FillRow(ByVal df, row, item, Optional excludeColOne = True)

    Dim i
    For i = LBound(df, 2) + Abs(excludeColOne) To UBound(df, 2)
        df(row, i) = item
    Next i
    
    FillRow = df

End Function



Function Filter(ByVal df, _
                ByVal criteria, _
                ByVal searchCol, _
                compareby As ComparerOp)

    criteria = ScalarToArray(criteria)
    searchCol = HeaderIndex(searchCol, df)
    Filter = Filter_Logic(df, criteria, searchCol, compareby)

End Function


Private Function Filter_Logic(ByVal df, _
                              ByVal criteria, _
                              ByVal searchCol, _
                              compareby As ComparerOp)
    Dim n
    n = 0
    
    '# Create index array and add header index
    ReDim indexArr(0 To UBound(df) - 1)
    indexArr(n) = 1

    '# Create New Body Array of Criteria Match
    Dim i
    For i = LBound(df) + 1 To UBound(df)

        Dim outcome As Boolean
        outcome = False
        
        If Not IsError(df(i, searchCol)) Then
            
            ReDim logicArr(0 To UBound(criteria))
            
            Dim j
            For j = LBound(logicArr) To UBound(logicArr)
                logicArr(j) = Compare(df(i, searchCol), criteria(j), compareby)
            Next j
            
        End If
        
            
        '# Check logicArr
        If compareby = DoesNotContain Or compareby = NotEqual Then
            If ArraySum(logicArr) = (UBound(criteria) + 1) * -1 Then
                outcome = True
            End If
        Else
            If ArraySum(logicArr) < 0 Then
                outcome = True
            End If
        End If
               
               
        If outcome = True Then
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
        
        For j = LBound(df, 2) To UBound(df, 2)
            tempdf(incr, j) = df(index, j)
        Next j
        
        incr = incr + 1
        
    Next index
    
    
    Filter_Logic = tempdf

End Function




Function FilterCols(ByVal df, _
                    ByVal criteria, _
                    compareby As ComparerOp, _
                    Optional startAfterCol = 0)

    ReDim colArr(0 To UBound(df, 2))
    
    Dim incr
    incr = 0
    
    Dim i
    For i = 1 To startAfterCol
        colArr(incr) = i
        incr = incr + 1
    Next i
    
    For i = startAfterCol + 1 To UBound(df, 2)
        
        Dim outcome As Boolean
        
        If IsError(df(1, i)) Then
            outcome = False
        Else
            outcome = Compare(df(1, i), criteria, compareby)
        End If
        
        If outcome Then
            colArr(incr) = df(1, i)
            incr = incr + 1
        End If
        
    Next i
    
    If incr > 0 Then
        ReDim Preserve colArr(0 To incr - 1)
        df = SelectCols(df, colArr)
    Else
        ReDim df(1 To 1, 1 To 1)
        df(1, 1) = "NO DATA"
        Debug.Print "<!WARNING!>: NO DATA"
    End If
        
    FilterCols = df

End Function



Private Function Filter_Fast(ByVal df, _
                             ByVal criteria, _
                             ByVal searchCol)

    '------------------------------------------------------
    '# Description:
    '# Assumes that you get a sorted array. Once it find a
    '# match it assumes that is the start. Incraments an
    '# an array until ther is no longer a match. Then fills
    '# new df with ony the indexes (contigous) in array
    '------------------------------------------------------

    Dim n
    n = 0

    '# Create index array and add header index
    ReDim indexArr(0 To UBound(df) - 1)
    indexArr(n) = 1

    Dim found
    found = 0

    '# Create new body array of criteria match
    Dim i
    For i = LBound(df) + 1 To UBound(df)

        If df(i, searchCol) = criteria Then
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






Function ArraySum(arr)

    Dim sum
    
    Dim elem
    For Each elem In arr
        If IsNumeric(elem) Then
            sum = sum + elem
        End If
    Next elem
    
    ArraySum = sum
    
End Function



Function FindColName(ByVal df, _
                     ByVal criteria, _
                     compareby As ComparerOp)

    Dim pos
    pos = FindColPosition(df, criteria, compareby)
    
    FindColName = df(1, pos)

End Function



Function FindColPostion(ByVal df, _
                        ByVal criteria, _
                        compareby As ComparerOp)

    Dim pos
    
    Dim i
    For i = LBound(df, 2) To UBound(df, 2)
        
        Dim outcome As Boolean
        
        If IsError(df(1, i)) Then
            outcome = False
        Else
            outcome = Compare(df(1, i), criteria, compareby)
        End If
        
        If outcome Then
            pos = i
            Exit For
        End If
    
    Next i
    
    FindColPosition = pos
    
End Function



Function Flip(ByVal df)

    ReDim tempdf(1 To UBound(df), 1 To UBound(df, 2))

    Dim pos
    pos = 2

    Dim i
    Dim j
    
    '# Assign Headers
    For i = LBound(df, 2) To UBound(df, 2)
        tempdf(1, i) = df(1, i)
    Next i

    For i = UBound(df) To LBound(df) + 1 Step -1
        For j = LBound(df, 2) To UBound(df, 2)
            tempdf(pos, j) = df(i, j)
        Next j

        pos = pos + 1

    Next i

    Flip = tempdf

End Function




Function FullJoin2(ByVal df, ByVal joindf, ByVal onCols)
    
    Dim tempdf
    tempdf = SelectCols(joindf, onCols)
    tempdf = AddGroupIndex(tempdf, onCols)
    tempdf = Filter(tempdf, 1, "GROUP_INDEX", GreaterThan)
    tempdf = DropCol(tempdf, "GROUP_INDEX")
    tempdf = Join(tempdf, onCols, df, , , False)
    
    
    df = Stack(df, tempdf)
    df = Sort(df, onCols)
    FullJoin2 = df
    
End Function




Function FullJoin(ByVal df, _
                  ByVal onCols, _
                  ByVal joindf, _
                  Optional joinCols, _
                  Optional rightOn, _
                  Optional includeDupes = False)


    If includeDupes Then
        FullJoin = FullJoin_DUPES(df, onCols, joindf, joinCols, rightOn)
    Else
        FullJoin = FullJoin_NO_DUPES(df, onCols, joindf, joinCols, rightOn)
    End If
    
End Function




Function FullJoin_DUPES(ByVal df, ByVal onCols, ByVal joindf, Optional joinCols, Optional rightOn)
    
    '# Duplicating rows where there are multiple matches
    Dim tempdf
    tempdf = SelectCols(joindf, onCols)
    tempdf = AddGroupIndex(tempdf, onCols)
    tempdf = Filter(tempdf, 1, "GROUP_INDEX", GreaterThan)
    tempdf = DropCol(tempdf, "GROUP_INDEX")
    tempdf = Join(tempdf, onCols, df, , , False)
    df = Stack(df, tempdf)
    df = Sort(df, onCols)
    
    onCols = ScalarToArray(onCols)

    If IsMissing(rightOn) Then
        rightOn = onCols
    Else
        rightOn = ScalarToArray(rightOn)
    End If
    
    '# Bringing in Duplicate Data by adding group index
    df = AddGroupIndex(df, onCols)

    joindf = AddGroupIndex(joindf, rightOn)
    
    onCols = ArrayCombine(onCols, Array("GROUP_INDEX"))
    rightOn = ArrayCombine(rightOn, Array("GROUP_INDEX"))


    Dim onElems
    onElems = SelectCols(df, onCols)
    
    rightOn = HeaderIndex(rightOn, joindf)
    
    Dim i
    For i = LBound(onCols) To UBound(onCols)
        joindf(1, rightOn(i)) = onCols(i)
    Next i
    
    Dim rightOnElems
    rightOnElems = SelectCols(joindf, onCols)

    onElems = Stack(onElems, rightOnElems)
    onElems = Unique(onElems, onCols)

    tempdf = Join(onElems, onCols, df, , , False)
    tempdf = Join(tempdf, onCols, joindf, joinCols, , False)
    tempdf = DropCol(tempdf, "GROUP_INDEX")
    
    FullJoin_DUPES = tempdf
    
End Function



Function FullJoin_NO_DUPES(ByVal df, onCols, ByVal joindf, Optional joinCols, Optional rightOn)

    onCols = ScalarToArray(onCols)
    
    Dim onElems
    onElems = SelectCols(df, onCols)
    
    If IsMissing(rightOn) Then
        rightOn = onCols
    Else
        rightOn = ScalarToArray(rightOn)
    End If
    
    rightOn = HeaderIndex(rightOn, joindf)
    
    Dim i
    For i = LBound(onCols) To UBound(onCols)
        joindf(1, rightOn(i)) = onCols(i)
    Next i
    
    Dim rightOnElems
    rightOnElems = SelectCols(joindf, onCols)
    
    onElems = Stack(onElems, rightOnElems)
    onElems = Unique(onElems, onCols)
    
    Dim tempdf
    tempdf = Join(onElems, onCols, df, , , False)
    tempdf = Join(tempdf, onCols, joindf, joinCols, , False)
    
    FullJoin_NO_DUPES = tempdf
    
End Function













Function FolderData(filesFldrPath)

    Dim fso As FileSystemObject
    Set fso = New FileSystemObject
    
    Dim fldr As Folder
    Set fldr = fso.GetFolder(filesFldrPath)
 
    If fldr.SubFolders.Count > 0 Then
    
        ReDim df(1 To fldr.SubFolders.Count + 1, 1 To 2)
        
        df(1, 1) = "Name"
        df(1, 2) = "Path"
    
        Dim i As Long
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



Function FolderNames(foldersPath)
    
    Dim fso As FileSystemObject
    Set fso = New FileSystemObject
    
    Dim fldr As Folder
    Set fldr = fso.GetFolder(foldersPath)
    
    If fldr.SubFolders.Count > 0 Then
    
        ReDim df(1 To fldr.SubFolders.Count + 1, 1 To 1)
        
        df(1, 1) = "Name"
        
        Dim i As Long
        i = 2
        
        Dim sfldr As Folder
        For Each sfldr In fldr.SubFolders
            df(i, 1) = sfldr.name
            i = i + 1
        Next sfldr
    
    Else
        ReDim df(1 To 1, 1 To 1)
    End If
    
    FolderNames = df
    
End Function



Function GetColNames(df, indexes)
    
    ReDim arr(0 To UBound(indexes))
    
    Dim i
    For i = LBound(indexes) To UBound(indexes)
        arr(i) = df(1, indexes(i))
    Next i
    
    GetColNames = arr

End Function



Function GetData(Optional wbPath = "", _
                 Optional wb As Workbook, _
                 Optional wsName As String = "", _
                 Optional startRow As Long = 1, _
                 Optional StartCol As Long = 1, _
                 Optional endRow As Long = 0, _
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
    Dim colCount As Long
    If endCol = 0 Then
        colCount = ws.Cells(startRow, Columns.Count).End(xlToLeft).Column
    Else
        colCount = endCol
    End If
    
    '# Row Count
    Dim rowCount As Long
    If endRow = 0 Then
        Dim i
        For i = StartCol To colCount
            Dim tempRow As Long
            tempRow = ws.Cells(Rows.Count, i).End(xlUp).row
            If tempRow > rowCount Then
                rowCount = tempRow
            End If
        Next i
    Else
        rowCount = endRow
    End If
    
    GetData = ws.Range( _
        ws.Cells(startRow, StartCol), _
        ws.Cells(rowCount, colCount) _
    )
    
    If wbPath <> "" Then
        wb.Close False
    End If
    
End Function



Function GetElement(ByVal df, _
                    ByVal col, _
                    ByVal row As Long)

    col = HeaderIndex(col, df)
    GetElement = df(row, col)

End Function


Function RollUp(ByVal df, categoryCols, numCols)
    
    categoryCols = ScalarToArray(categoryCols)
    numCols = ScalarToArray(numCols)
    
    Dim keepCols
    keepCols = ArrayCombine(categoryCols, numCols)

    df = SelectCols(df, keepCols)
    df = SplitOnCol(df, categoryCols)
    
    Dim finaldf
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        
        Dim tempdf
        tempdf = df(i, 2)
        tempdf = AddTotalRow(tempdf, numCols)
        tempdf(UBound(tempdf), 1) = "Total"
        tempdf = Filter(tempdf, "Total", 1, EqualTo)
        
        Dim catarr
        catarr = Split(df(i, 1), "<|>")
               
        Dim j
        For j = LBound(catarr) To UBound(catarr)
            tempdf(2, j + 1) = catarr(j)
        Next j
        
        finaldf = Stack(finaldf, tempdf)
    Next i
    
    RollUp = finaldf
    
End Function

Function Group(ByVal df, _
               ByVal groupCols, _
               Optional ByVal numCol, _
               Optional aggregator As AggragatorOp = countAggr, _
               Optional includeCount = False)
               
    groupCols = ScalarToArray(groupCols)

    If IsMissing(numCol) Then
        df = SelectCols(df, groupCols)
    Else
        numCol = ScalarToArray(numCol)
        df = SelectCols(df, ArrayCombine(groupCols, numCol))
    End If
        
    Dim tempdf
    tempdf = SplitOnCol(df, groupCols)
    tempdf(1, 2) = "NESTED_ARR"

    Dim CountCol
    CountCol = 2
    
    Dim i
    
    '# Check for numcols and default to "count"
    If Not IsMissing(numCol) And aggregator <> countAggr Then
        
        numCol = HeaderIndex(numCol, df)
        
        ReDim Preserve tempdf(1 To UBound(tempdf), 1 To UBound(tempdf, 2) + UBound(numCol) + 1)
        
        For i = LBound(numCol) To UBound(numCol)
            tempdf(1, 3 + i) = df(1, numCol(i))
        Next i
        
    End If
    
    If aggregator = countAggr Or includeCount Then
        
        ReDim Preserve tempdf(1 To UBound(tempdf), 1 To UBound(tempdf, 2) + 1)
        CountCol = UBound(tempdf, 2)
        tempdf(1, CountCol) = "Count"
        
    End If
    

    '# Begin Loop and Aggregation
    For i = LBound(tempdf) + 1 To UBound(tempdf)
    
        Dim splitdf
        splitdf = tempdf(i, 2)
        
        If Not IsMissing(numCol) And aggregator <> countAggr Then
            
            Dim j
            For j = LBound(numCol) To UBound(numCol)
            
                '# Sum
                If aggregator = sumAggr Then
                    tempdf(i, 3 + j) = SumCols_Logic(splitdf, Array(numCol(j)))
                End If
                
                '# mean
                If aggregator = meanAggr Then
                    tempdf(i, 3 + j) = ColMean_Logic(splitdf, numCol(j))
                End If
                
                '# Median
                If aggregator = medianAggr Then
                    tempdf(i, 3 + j) = GroupMedian(splitdf, numCol(j))
                End If
                
                '# Min
                If aggregator = minAggr Then
                    tempdf(i, 3 + j) = GroupMinMax(splitdf, numCol(j), False)
                End If
                
                '# Max
                If aggregator = maxAggr Then
                    tempdf(i, 3 + j) = GroupMinMax(splitdf, numCol(j))
                End If
                
                '# SDev Population
                If aggregator = sdevpAggr Then
                    tempdf(i, 3 + j) = GroupStandardDev(splitdf, numCol(j), True)
                End If
                
                '# SDev Sample
                If aggregator = sdevAggr Then
                    tempdf(i, 3 + j) = GroupStandardDev(splitdf, numCol(j))
                End If
            
            Next j
            
        End If
        
        '# Count
        If aggregator = countAggr Or IsMissing(numCol) Or includeCount Then
            tempdf(i, CountCol) = UBound(splitdf) - 1
        End If
        
    Next i
    
    
    tempdf = DropCol(tempdf, "NESTED_ARR")

    '# Split out groupcols concatenated
    Dim pos As Long
    pos = 2
    
    If UBound(groupCols) > 0 Then
        
        For i = LBound(groupCols) + 1 To UBound(groupCols)
            tempdf = AddCols(tempdf, groupCols(i))
            tempdf = MoveCol(tempdf, groupCols(i), pos)
            pos = pos + 1
        Next i
        
        tempdf = SplitData( _
            df:=tempdf, _
            col:=1, _
            colsToFill:=Arrange(1, UBound(groupCols) + 1), _
            delimiter:="<|>", _
            skipHead:=False _
        )
        
    End If
    
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

    Sort_Logic _
        df:=df, _
        sortOnCol:=CLng(col), _
        lowerBounds:=2, _
        UpperBounds:=UBound(df)
        
    
    If max Then
        GroupMinMax = df(UBound(df), col)
    Else
        GroupMinMax = df(2, col)
    End If
    
End Function



Private Function GroupStandardDev(ByVal df, col, Optional population = False)

    Dim standardDev
    
    Dim n
    n = UBound(df) '- 1 '#Minus 1 to correct for columns
        
    If n > 1 Then
    
        Dim xBar
        xBar = SumCols(df, col) / n
        
        If population = False Then
            n = n - 1
        End If
        
        Dim summation
        summation = 0
        
        Dim i
        For i = LBound(df) + 1 To UBound(df)
            summation = summation + (df(i, col) - xBar) ^ 2
        Next i

        standardDev = (summation / n) ^ 0.5
    Else
        standardDev = 0
    End If
    
    GroupStandardDev = standardDev
    
End Function



Function HeaderIndex(ByVal ColNames, ByVal df)

    If IsArray(ColNames) = True Then
        HeaderIndex = HeaderIndexList(ColNames, df)
    Else
    
        If IsNumeric(ColNames) = False Then
            HeaderIndex = HeaderIndexScalar(ColNames, df)
         Else
            HeaderIndex = ColNames * 1
        End If
        
    End If
    
End Function



Private Function HeaderIndexList(ByVal headerList, ByVal arr)

    Dim i
    For i = LBound(headerList) To UBound(headerList)
        If IsNumeric(headerList(i)) = False Then
            headerList(i) = HeaderIndexScalar(headerList(i), arr)
        End If
    Next i

    HeaderIndexList = headerList

End Function



Private Function HeaderIndexScalar(ByVal ColNames, ByVal df)

    Dim i
    For i = LBound(df, 2) To UBound(df, 2)
        If df(1, i) = ColNames Then
            Exit For
        ElseIf i = UBound(df, 2) Then
            Debug.Print "<!ERROR!> Header " & ColNames & " does NOT exist"
        End If
    Next i
    
    HeaderIndexScalar = i

End Function



Function HeaderValidation(ByVal df, _
                          header, _
                          Optional invalidReturn = "Header does not exist")

    Dim pos
    pos = HeaderIndex(header, df)
    
    If pos = "<!ERROR!>" Then
        HeaderValidation = invalidReturn
    Else
        HeaderValidation = header
    End If
    
End Function



Function InsertTopRow(ByVal df, Optional headers = True)
    
    Dim origUpBound
    origUpBound = UBound(df)
    
    df = Reshape(df, UBound(df) + 1, UBound(df, 2))
    
    Dim i
    For i = UBound(df) To (LBound(df) + Abs(headers) + 1) Step -1
        
        Dim j
        For j = LBound(df, 2) To UBound(df, 2)
            df(i, j) = df(i - 1, j)
        Next j
    Next i

    '# Clear Top Row
    For j = LBound(df, 2) To UBound(df, 2)
        df(1 + Abs(headers), j) = ""
    Next j

    InsertTopRow = df

End Function



Function Join(ByVal df, _
              ByVal onCols, _
              ByVal joindf, _
              Optional ByVal joinCols, _
              Optional rightOn, _
              Optional indicator = True)

              
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
            colstr = colstr & rightOn(i) & "//"
        Next i
        
        ReDim joinCols(0 To UBound(joindf, 2) - UBound(rightOn) - 2)
        
        Dim incr
        incr = 0
        
        For i = LBound(joindf, 2) To UBound(joindf, 2)
            If InStr(colstr, joindf(1, i) & "//") = 0 Then
                joinCols(incr) = joindf(1, i)
                incr = incr + 1
            End If
        Next i
        
    Else
        joinCols = ScalarToArray(joinCols)
    End If
    
    df = Join_Logic( _
        df:=df, _
        leftOn:=onCols, _
        joindf:=joindf, _
        rightOn:=rightOn, _
        joinCols:=joinCols, _
        indicator:=indicator _
    )
    
    ' Remove LeftJoinCols Column
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) - 1)
    
    Join = df
    
End Function



Private Function Join_Logic(ByVal df, _
                            ByVal leftOn, _
                            ByVal joindf, _
                            ByVal rightOn, _
                            ByVal joinCols, _
                            Optional indicator = True)

    Dim origColCount
    origColCount = UBound(df, 2)
                         
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + UBound(joinCols) + 1)
    
    Dim i As Long
    For i = LBound(joinCols) To UBound(joinCols)
        df(1, i + origColCount + 1) = joinCols(i)
    Next i
    
    '# Logic for Indicator
    If indicator Then
        ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
        df(1, UBound(df, 2)) = "_Join"
        df = fillCol(df, "_Join", "left_only")
    End If
    
    
    '# Left Join Cols Logic
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
    df(1, UBound(df, 2)) = "LeftJoinCols"
    df = Concat(df, UBound(df, 2), leftOn, INTERNAL_SEP)
    
    
    '# Prepare Right Join
    ReDim Preserve joindf(1 To UBound(joindf), 1 To UBound(joindf, 2) + 1)
    joindf = Concat(joindf, UBound(joindf, 2), rightOn, INTERNAL_SEP)
    

    '# joinCols header search comes after reshape so that
    '# Reshape can extract col names
    joinCols = HeaderIndex(joinCols, joindf)
    
    
    '#Header Index Match df
    Sort_Logic _
        df:=joindf, _
        sortOnCol:=UBound(joindf, 2), _
        lowerBounds:=LBound(joindf) + 1, _
        UpperBounds:=UBound(joindf)
   
    
    For i = LBound(df) + 1 To UBound(df)

        Dim rowPos As Variant
        rowPos = Search_Logic(df(i, UBound(df, 2)), joindf, UBound(joindf, 2))
        
        If rowPos <> NO_POSITION_ERR Then
            
            Dim j As Long
            For j = LBound(joinCols) To UBound(joinCols)
                df(i, j + origColCount + 1) = joindf(rowPos, joinCols(j))
            Next j
            
            If indicator Then
                df(i, UBound(df, 2) - 1) = "both"
            End If
        
        End If
       
    Next i
    
    Join_Logic = df

End Function



Function Match(ByVal df, _
               ByVal onCols, _
               ByVal matchDF, _
               Optional rightOn)

    '# Concatenate Join columns
    onCols = ScalarToArray(onCols)
    
    If IsMissing(rightOn) Then
        rightOn = onCols
    Else
        rightOn = ScalarToArray(rightOn)
    End If
    
    '# Concat columns that are going to be used to match
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
    df(1, UBound(df, 2)) = "LeftJoinCols"
    df = Concat(df, UBound(df, 2), onCols, INTERNAL_SEP)

    ReDim Preserve matchDF(1 To UBound(matchDF), 1 To UBound(matchDF, 2) + 1)
    matchDF = Concat(matchDF, UBound(matchDF, 2), rightOn, INTERNAL_SEP)
  
    df = Match_Logic( _
        df:=df, _
        leftOn:=UBound(df, 2), _
        matchDF:=matchDF, _
        rightOn:=UBound(matchDF, 2), _
        indicator:=True _
    )
    
    df = DropCol(df, "LeftJoinCols")

    Match = df
    
End Function



Private Function Match_Logic(ByVal df, _
                            ByVal leftOn, _
                            ByVal matchDF, _
                            ByVal rightOn, _
                            Optional indicator = True)

    Dim origColCount
    origColCount = UBound(df, 2)
    
    '#Header Index Match df
    matchDF = Sort(matchDF, Array(rightOn))
    
    If indicator Then
        df = AddCols(df, "_Join")
        df = fillCol(df, "_Join", "left_only")
    End If
    
    Dim i
    
    Dim searchDF
    searchDF = SelectCols(matchDF, rightOn)
   
    For i = LBound(df) + 1 To UBound(df)

        Dim rowPos As Variant
        rowPos = Search_Logic(df(i, leftOn), searchDF, 1)
        
        If rowPos <> NO_POSITION_ERR Then
            df(i, UBound(df, 2)) = "both"
        End If
       
    Next i
    
    Match_Logic = df

End Function



Function Math(ByVal df, _
              ByVal colToFill, _
              ByVal mathCols, _
              mathOperation As MathOp, _
              Optional constant)

    colToFill = HeaderIndex(colToFill, df)
    mathCols = ScalarToArray(mathCols)
    mathCols = HeaderIndex(mathCols, df)
    
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        If UBound(mathCols) > 0 Then
            
            Dim mTotal
            mTotal = df(i, mathCols(0))
        
            Dim j
            For j = LBound(mathCols) + 1 To UBound(mathCols)
                mTotal = Math_Logic(mTotal, df(i, mathCols(j)), mathOperation)
            Next j
                            
            df(i, colToFill) = mTotal
            
        Else
            df(i, colToFill) = df(i, mathCols(0))
        End If
        
        
        If Not IsMissing(constant) Then
            df(i, colToFill) = Math_Logic(df(i, colToFill), constant, mathOperation)
        End If
                
    Next i

    Math = df
    
End Function



Private Function Math_Logic(ByVal operand_1, _
                            ByVal operand_2, _
                            mathOperation As MathOp)

    If operand_1 = "" Then
    operand_1 = 0
    End If
    
    If operand_2 = "" Then
    operand_2 = 0
    End If
    
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



Function MinMaxReturn(ByVal df, _
                      groupCol, _
                      searchCol, _
                      returnCol, _
                      Optional min = True, _
                      Optional colName = "MinMax", _
                      Optional returnSearchCol = False)
    
    groupCol = HeaderIndex(groupCol, df)
    searchCol = HeaderIndex(searchCol, df)
    returnCol = HeaderIndex(returnCol, df)
        
    Dim tempdf
    tempdf = SplitOnCol(df, groupCol, colName)
    
    If returnSearchCol Then
        ReDim Preserve tempdf(1 To UBound(tempdf), 1 To UBound(tempdf, 2) + 1)
        tempdf(1, UBound(tempdf, 2)) = df(1, searchCol)
    End If
        
    Dim i
    For i = LBound(tempdf) + 1 To UBound(tempdf)
        
        Dim splitdf
        splitdf = tempdf(i, 2)
        
        Sort_Logic splitdf, CLng(searchCol), 2, UBound(splitdf)
        
        Dim tempstr As String
        Dim j

        If min Then
        
            tempstr = splitdf(2, returnCol)
            
            For j = LBound(splitdf) + 2 To UBound(splitdf)
                If splitdf(j, searchCol) = splitdf(j - 1, searchCol) Then
                    tempstr = tempstr & "; " & splitdf(j, returnCol)
                Else
                    Exit For
                End If
            Next j
            
            If returnSearchCol Then
                tempdf(i, 3) = splitdf(2, searchCol)
            End If
            
        Else
            tempstr = splitdf(UBound(tempdf(i, 2)), returnCol)
            
            For j = UBound(splitdf) - 1 To LBound(splitdf) + 1 Step -1
                If splitdf(j, searchCol) = splitdf(j + 1, searchCol) Then
                    tempstr = tempstr & "; " & splitdf(j, returnCol)
                Else
                    Exit For
                End If
            Next j
            
            If returnSearchCol Then
                tempdf(i, 3) = splitdf(UBound(tempdf(i, 2)), searchCol)
            End If
            
        End If
        
        tempdf(i, 2) = tempstr
            
    Next i
    
    MinMaxReturn = tempdf
    
End Function


Function MonthNum(ByVal df, col)
    
    col = HeaderIndex(col, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        Select Case LCase(df(i, col))
            
            Case "january", "jan"
                df(i, col) = 1
                
            Case "february", "feb"
                df(i, col) = 2
                
            Case "march", "mar"
                df(i, col) = 3
                
            Case "april", "apr"
                df(i, col) = 4
                
            Case "may"
                df(i, col) = 5
                
            Case "june", "jun"
                df(i, col) = 6
                
            Case "july", "jul"
                df(i, col) = 7
                
            Case "august", "aug"
                df(i, col) = 8
                
            Case "september", "sep"
                df(i, col) = 9
                
            Case "october", "oct"
                df(i, col) = 10
            
            Case "november", "nov"
                df(i, col) = 11
            
            Case "december", "dec"
                df(i, col) = 12
                
        End Select
    
    Next i
    
    MonthNum = df
    
End Function


Function MonthName(ByVal df, col)
    
    col = HeaderIndex(col, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
  
        Select Case CInt(df(i, col))
            
            Case 1
                df(i, col) = "January"
                
            Case 2
                df(i, col) = "February"
                
            Case 3
                df(i, col) = "March"
                
            Case 4
                df(i, col) = "April"
                
            Case 5
                df(i, col) = "May"
                
            Case 6
                df(i, col) = "June"
                
            Case 7
                df(i, col) = "July"
                
            Case 8
                df(i, col) = "August"
                
            Case 9
                df(i, col) = "September"
                
            Case 10
                df(i, col) = "October"
            
            Case 11
                df(i, col) = "November"
            
            Case 12
                df(i, col) = "December"
                
        End Select
    
    Next i
    
    MonthName = df
    
End Function


Function MoveCol(ByVal df, _
                 ByVal col, _
                 newPosition As Long)

    col = HeaderIndex(col, df)
    MoveCol = MoveCol_Logic(df, col, newPosition)
    
End Function



Private Function MoveCol_Logic(ByVal df, _
                               ByVal col, _
                               newPosition As Long)

    Dim i
    
    If col < newPosition Then
        For i = col To newPosition - 1
            df = SwapCols_Logic(df, i, i + 1)
        Next i
    Else
        For i = col To newPosition + 1 Step -1
            df = SwapCols_Logic(df, i, i - 1)
        Next i
    End If
       
    MoveCol_Logic = df
    
End Function



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



Function Pivot(ByVal df, _
               categoryCols, _
               headerCol, _
               Optional valueCol, _
               Optional aggregator As AggragatorOp = meanAggr)

    categoryCols = ScalarToArray(categoryCols)

    df = MoveCol(df, categoryCols(0), 1)
    df = Concat(df, categoryCols(0), categoryCols, "<|PIVOT|>", False)
    
    If IsMissing(valueCol) Then
        df = SelectCols(df, Array(df(1, 1), headerCol))
    Else
        df = SelectCols(df, Array(df(1, 1), headerCol, valueCol))
    End If
         
  
    Dim finaldf
    finaldf = Unique(df, df(1, 1))

    Dim headerdf
    headerdf = Unique(df, 2)
    
    Dim i
    For i = LBound(headerdf) + 1 To UBound(headerdf)
    
        Dim tempdf
        tempdf = Filter_Fast(df, headerdf(i, 1), 2)
        
        If IsMissing(valueCol) Then
            tempdf = Group(tempdf, tempdf(1, 1), , countAggr)
        Else
            tempdf = Group(tempdf, tempdf(1, 1), tempdf(1, 3), aggregator)
        End If
        
        tempdf(1, 2) = headerdf(i, 1)
        
        finaldf = Join(finaldf, 1, tempdf, headerdf(i, 1), , False)
        
    Next i
    
    
    Dim pos As Long
    pos = 2
    
    If UBound(categoryCols) > 0 Then
        
        Dim k
        For k = LBound(categoryCols) + 1 To UBound(categoryCols)
            finaldf = AddCols(finaldf, categoryCols(k))
            finaldf = MoveCol(finaldf, categoryCols(k), pos)
            pos = pos + 1
        Next k
        
        finaldf = SplitData(finaldf, 1, Arrange(1, UBound(categoryCols) + 1), "<|PIVOT|>", False)
    
    End If

    Pivot = finaldf

End Function


Function PrintColNames(df, Optional delim = "")
    
    Dim ColNames
    ColNames = ""
    
    Dim i
    For i = LBound(df, 2) To UBound(df, 2)
        If Len(ColNames) > 75 Then
            Debug.Print ColNames
            ColNames = ""
        ElseIf ColNames = "" Then
            ColNames = df(1, i)
        Else
            ColNames = ColNames & delim & df(1, i)
        End If
    Next i
    
    Debug.Print ColNames
    
End Function



Function PVal(ByVal df, _
              ByVal sourceCol, _
              ByVal colToFill, _
              ByVal rate As Double, _
              Optional startIndex = 1)

    sourceCol = HeaderIndex(sourceCol, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = PV( _
            rate:=rate, _
            NPer:=startIndex + i - 2, _
            Pmt:=0, _
            FV:=df(i, sourceCol) * -1 _
        )
    Next i

    PVal = df

End Function





Function RemoveEndCols(ByVal df, colCount)
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) - colCount)
    RemoveEndCols = df
End Function



Function ReplaceStr(ByVal df, sourceCol, colToFill, findElem, replaceElem)

    sourceCol = HeaderIndex(sourceCol, df)
    colToFill = HeaderIndex(colToFill, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = Replace(df(i, sourceCol), findElem, replaceElem)
    Next i
    
    ReplaceStr = df
    
End Function



Function Reshape(ByVal df, _
                 rowCount, _
                 colCount, _
                 Optional addedColNames)

    '# Column Reshape
    Dim originalCount As Long
    originalCount = UBound(df, 2)
    
    ReDim Preserve df(1 To UBound(df), 1 To colCount)
 
    '# Fill Headers
    If IsArray(addedColNames) = True Then
    
        Dim i
        For i = LBound(addedColNames) To UBound(addedColNames)
            df(1, originalCount + 1 + i) = addedColNames(i)
        Next i
        
    End If
    
    Reshape = Reshape_Row_Logic(df, rowCount)

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



Function RoundNum(ByVal df, _
                  ByVal cols, _
                  Optional digitCount As Long = 0)

    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df)
        
        Dim j
        For j = LBound(cols) To UBound(cols)
            If IsNumeric(df(i, cols(j))) Then
                df(i, cols(j)) = Round(df(i, cols(j)), digitCount)
            End If
        Next j
        
    Next i

    RoundNum = df

End Function



Function RowDropEnd(ByVal df, row, charCount As Long, Optional startPos As Long = 1)

    Dim i
    For i = startPos To UBound(df, 2)
        
        Dim tempstr
        tempstr = df(row, i)
        df(row, i) = Left(tempstr, Len(tempstr) - charCount)
        
    Next i
    
    RowDropEnd = df
    
End Function



Function RowToArr(ByVal df, row, Optional endCol, Optional StartCol = 1)
    
    ReDim temparr(0 To UBound(df, 2) - 1)
    
    Dim i
    For i = StartCol To UBound(df, 2)
        temparr(i - StartCol) = df(CLng(row), CLng(i))
    Next
    
    RowToArr = temparr
    
End Function



Sub RowToCmbx(ByVal df, _
              ByVal row, _
              ByVal cmbx As ComboBox, _
              Optional displayItemOne As Boolean = True)

    Dim headdf
    headdf = RowToCol(df, row)
    headdf = Sort(headdf, 1)
    ColToCmbx headdf, 1, cmbx, displayItemOne, True

End Sub



Function RowToCol(df, _
                  selectedRow, _
                  Optional headerName = "<ROW1>")

    ReDim tempdf(1 To UBound(df, 2) + 1, 1 To 1)
 
    Dim i
    For i = LBound(tempdf) + 1 To UBound(tempdf)
        tempdf(i, 1) = df(selectedRow, i - 1)
    Next i

    tempdf(1, 1) = headerName

    RowToCol = tempdf

End Function



Private Function ScalarToArray(scalar)
    
    If IsArray(scalar) = False Then
        ScalarToArray = Array(scalar)
    Else
        ScalarToArray = scalar
    End If

End Function



Function ScaleData(ByVal df, StartCol, factor)

    Dim i
    For i = StartCol To UBound(df, 2)
        
        Dim j
        For j = LBound(df) + 1 To UBound(df)
            df(j, i) = df(j, i) * factor
        Next j
    Next i

    ScaleData = df

End Function



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
    foundPos = NO_POSITION_ERR
    
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



Function SelectLeft(ByVal df, _
                    ByVal col, _
                    ByVal colToFill, _
                    charCount As Long)

    col = HeaderIndex(col, df)
    colToFill = HeaderIndex(colToFill, df)

    Dim i As Long
    For i = LBound(df) + 1 To UBound(df)
        df(i, colToFill) = Left(df(i, col), charCount)
    Next i

    SelectLeft = df

End Function



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



Function SeqDF(startNumber, _
               numberCount, _
               Optional Step = 1, _
               Optional headerName = "<Header1>")

    ReDim tempdf(1 To numberCount + 1, 1 To 1)

    Dim i As Long
    For i = LBound(tempdf) + 1 To UBound(tempdf)
        tempdf(i, 1) = startNumber + (i - 2) * Step
    Next i

    '# Fill in headers
    tempdf(1, 1) = headerName

    SeqDF = tempdf

End Function



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



Function ShiftDown(ByVal df, _
                   valueCol, _
                   Optional groupCols, _
                   Optional name = "shifted_down")

    '------------------------------------------------------
    '# Description:
    '# Shifts a columns data down. This would be useful in
    '# a caclulation of growth from previous month
    '------------------------------------------------------
    
    If Not IsMissing(groupCols) Then
        groupCols = ScalarToArray(groupCols)
        groupCols = HeaderIndex(groupCols, df)
    End If
    
    valueCol = HeaderIndex(valueCol, df)
    
    df = AddCols(df, name)
    
    Dim i
    For i = LBound(df) + 1 To UBound(df) - 1
        
        Dim inGroup
        inGroup = True
        
        If Not IsMissing(groupCols) Then
        
            Dim j
            For j = LBound(groupCols) To UBound(groupCols)
                
                If df(i, groupCols(j)) <> df(i + 1, groupCols(j)) Then
                    inGroup = False
                End If
            Next j
        
        End If
        
        If inGroup Then
            df(i + 1, UBound(df, 2)) = df(i, valueCol)
        End If
    
    Next i
    
    ShiftDown = df

End Function



Function Sort(ByVal df, ByVal sortCols, Optional ascending As Boolean = True)
    
    sortCols = ScalarToArray(sortCols)
    sortCols = HeaderIndex(sortCols, df)
    
    '# Add concatenate column
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
    
    '# Concatenate sort columns
    df = Concat(df, UBound(df, 2), sortCols, INTERNAL_SEP)

    '# Sort Array
    If UBound(df) > 1 Then
        
        Sort_Logic _
            df:=df, _
            sortOnCol:=UBound(df, 2), _
            lowerBounds:=LBound(df) + 1, _
            UpperBounds:=UBound(df)
        
        '# Ascending
        If ascending = False Then
            df = Flip(df)
        End If
    
    End If
    
    '# Remove concatenated column
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) - 1)
    
    Sort = df
    
End Function



Function SortLevels(ByVal df, ByVal cols, Optional ByVal ascArr)

    If IsMissing(ascArr) Then
    
        ReDim ascArr(0 To UBound(cols))
        
        Dim m
        For m = 0 To UBound(cols)
            ascArr(m) = True
        Next m
        
    End If
    
    df = SplitOnCol(df, cols(0))
    
    Dim x As Boolean
    x = ascArr(0)
    
    df = Sort(df, cols(0), x)
    df = SelectCols(df, 2)
    
    cols = ArrayDrop(cols, 0)
    ascArr = ArrayDrop(ascArr, 0)
    
    Dim finaldf
    
    If Not IsEmpty(cols) Then
    
        Dim j
        For j = LBound(df) + 1 To UBound(df)
            Dim tempdf
            tempdf = SortLevels(df(j, 1), cols, ascArr)
            finaldf = Stack(finaldf, tempdf)
        Next j
    
    Else
        
        Dim i
        For i = LBound(df) + 1 To UBound(df)
            finaldf = Stack(finaldf, df(i, 1))
        Next i
    
    End If
    
    SortLevels = finaldf

End Function





Private Function Sort_Logic(df, _
                            sortOnCol As Long, _
                            lowerBounds As Long, _
                            UpperBounds As Long)

    Dim Pivot As Variant
    Pivot = df((lowerBounds + UpperBounds) \ 2, sortOnCol)
    
    '# Lower Index and Num
    Dim lowerIndex As Long
    lowerIndex = lowerBounds
    
    Dim lowerNum As Variant
    lowerNum = df(lowerIndex, sortOnCol)
    
    '# Upper Index and Num
    Dim upperIndex As Long
    upperIndex = UpperBounds
    
    Dim upperNum As Variant
    upperNum = df(upperIndex, sortOnCol)
        
    '# Sort
    Do While (lowerIndex <= upperIndex)
    
        '# Lower partition
        Do While lowerNum < Pivot
            lowerIndex = lowerIndex + 1
            lowerNum = df(lowerIndex, sortOnCol)
        Loop
        
        '# upper partition
        Do While upperNum > Pivot
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
        Sort_Logic _
            df:=df, _
            sortOnCol:=sortOnCol, _
            lowerBounds:=lowerBounds, _
            UpperBounds:=upperIndex
    End If
    
    
    If (lowerIndex < UpperBounds) Then
        Sort_Logic _
            df:=df, _
            sortOnCol:=sortOnCol, _
            lowerBounds:=lowerIndex, _
            UpperBounds:=UpperBounds
    End If
   
End Function



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

            Dim temparr
            temparr = Split(df(i, col), delimiter)

            If UBound(temparr) = UBound(colsToFill) Then
                
                Dim j As Long
                For j = LBound(colsToFill) To UBound(colsToFill)
                    df(i, colsToFill(j)) = temparr(j)
                Next j
                
            Else
                df(i, colsToFill(0)) = SPLIT_ERR
            End If

        End If

    Next i

    SplitData = df

End Function



Function SplitOnCol(ByVal df, ByVal categoryCols, Optional dfColName = "DataFrames")
  
    categoryCols = ScalarToArray(categoryCols)
    categoryCols = HeaderIndex(categoryCols, df)
    
    '# Add concatenate column
    ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
    
    '# Concatenate sort columns
    df = Concat(df, UBound(df, 2), categoryCols, "<|>", False)
    
    '# Sort df because we are using Filter_Fast
    Sort_Logic df, UBound(df, 2), LBound(df) + 1, UBound(df)
   
    Dim tempdf
    tempdf = Unique_Logic(df, Array(UBound(df, 2)))
    
    ReDim Preserve tempdf(1 To UBound(tempdf), 1 To 2)
    tempdf(1, 2) = dfColName

    Dim i
    For i = LBound(tempdf) + 1 To UBound(tempdf)

        Dim splitdf
        splitdf = Filter_Fast(df, tempdf(i, 1), UBound(df, 2))
        ReDim Preserve splitdf(1 To UBound(splitdf), 1 To UBound(splitdf, 2) - 1)
        tempdf(i, 2) = splitdf
        
    Next i

    SplitOnCol = tempdf

End Function



Function Stack(ByVal df1, ByVal df2)

    If IsEmpty(df1) Then
        Stack = df2
    Else
        Stack = Stack_Logic(df1, df2)
    End If

End Function



Function StackFromPaths(ByVal fileDataDf, Optional sourceColName = "Source")

    Dim i
    For i = LBound(fileDataDf) + 1 To UBound(fileDataDf)
        
        Dim path
        path = GetElement(fileDataDf, "Path", i)
        
        Dim tempdf
        tempdf = GetData(path)

        tempdf = AddCols(tempdf, sourceColName)
        
        tempdf = fillCol( _
            df:=tempdf, _
            colToFill:=sourceColName, _
            item:=GetElement(fileDataDf, "Name", i) _
        )

        Dim finaldf
        finaldf = Stack(finaldf, tempdf)
        
    Next i
    
    StackFromPaths = finaldf
    
End Function



Private Function Stack_Logic(ByVal df1, ByVal df2) ', origRows, Optional headers = True)

    Dim origRows
    origRows = UBound(df1)

    df1 = Reshape(df1, UBound(df1) + UBound(df2) - 1, UBound(df2, 2))

    If UBound(df1, 2) = UBound(df2, 2) Then

        Dim i
        For i = LBound(df2) + 1 To UBound(df2)
        
            Dim j
            For j = LBound(df1, 2) To UBound(df1, 2)
                df1(i + origRows - 1, j) = df2(i, j)
            Next j
        Next i

    Else
        Debug.Print "<!WARNING!> Helix Stack: Arrays do not have same column count"
    End If

    Stack_Logic = df1
    
End Function



Function StrClean(ByVal df, ByVal cols)

    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)

    Dim i
    For i = LBound(df) + 1 To UBound(df)
        
        Dim j
        For j = LBound(cols) To UBound(cols)
            df(i, cols(j)) = WorksheetFunction.Clean(df(i, cols(j)))
        Next j
        
    Next i

    StrClean = df

End Function



Function StrLow(ByVal df, ByVal cols)

    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)

    Dim i
    For i = LBound(df) + 1 To UBound(df)
        
        Dim j
        For j = LBound(cols) To UBound(cols)
            df(i, cols(j)) = LCase(df(i, cols(j)))
        Next j
        
    Next i

    StrLow = df

End Function



Function StrUp(ByVal df, ByVal cols)

    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)

    Dim i
    For i = LBound(df) + 1 To UBound(df)
        
        Dim j
        For j = LBound(cols) To UBound(cols)
            df(i, cols(j)) = UCase(df(i, cols(j)))
        Next j
        
    Next i

    StrUp = df

End Function



Function SumCols(ByVal df, ByVal cols)
    
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)
    
    SumCols = SumCols_Logic(df, cols)

End Function



Private Function SumCols_Logic(ByVal df, ByVal cols, Optional headers = True)
    
    Dim total As Double
    total = 0
    
    Dim i As Long
    For i = LBound(df) + Abs(headers) To UBound(df)
    
        Dim j As Long
        For j = LBound(cols) To UBound(cols)
            If IsNumeric(df(i, cols(j))) = True Then
                total = total + df(i, cols(j))
            End If
        Next j
        
    Next i
    
   SumCols_Logic = total

End Function



Function SumIf(ByVal df, _
               ByVal criteria, _
               ByVal searchCol, _
               ByVal sumCol, _
               compareby As ComparerOp)

    searchCol = HeaderIndex(searchCol, df)
    sumCol = HeaderIndex(sumCol, df)

    Dim total As Double

    Dim i
    For i = LBound(df) + 1 To UBound(df)
    
        Dim outcome As Boolean
        outcome = Compare(df(i, searchCol), criteria, compareby)

        If outcome = True Then
            total = total + df(i, sumCol)
        End If

    Next i

    SumIf = total

End Function


Function SummarizeGroup(ByVal df, _
                        ByVal groupCols, _
                        numCol, _
                        Optional sdevPop = False)

    groupCols = ScalarToArray(groupCols)
    numCol = ScalarToArray(numCol)
    df = SelectCols(df, ArrayCombine(groupCols, numCol))
  
    Dim tempdf
    tempdf = SplitOnCol(df, groupCols)
    tempdf(1, 2) = "NESTED_ARR"
    
    ReDim Preserve tempdf(1 To UBound(tempdf), 1 To UBound(tempdf, 2) + 7)
    tempdf(1, 3) = "Count"
    tempdf(1, 4) = "Sum"
    tempdf(1, 5) = "Mean"
    tempdf(1, 6) = "Median"
    tempdf(1, 7) = "Min"
    tempdf(1, 8) = "Max"
    tempdf(1, 9) = "SDev"
                       
    Dim i
    For i = LBound(tempdf) + 1 To UBound(tempdf)
    
        Dim splitdf
        splitdf = tempdf(i, 2)
        tempdf(i, 3) = UBound(splitdf) - 1
        tempdf(i, 4) = SumCols(splitdf, UBound(splitdf, 2))
        tempdf(i, 5) = ColMean_Logic(splitdf, UBound(splitdf, 2))
        tempdf(i, 6) = GroupMedian(splitdf, UBound(splitdf, 2))
        tempdf(i, 7) = GroupMinMax(splitdf, UBound(splitdf, 2), False)
        tempdf(i, 8) = GroupMinMax(splitdf, UBound(splitdf, 2), True)
        tempdf(i, 9) = GroupStandardDev(splitdf, UBound(splitdf, 2), sdevPop)
        
    Next i

    tempdf = DropCol(tempdf, "NESTED_ARR")
    
    '# Split out groupcols concatenated
    Dim pos As Long
    pos = 2
    
    If UBound(groupCols) > 0 Then
        
        For i = LBound(groupCols) + 1 To UBound(groupCols)
            tempdf = AddCols(tempdf, groupCols(i))
            tempdf = MoveCol(tempdf, groupCols(i), pos)
            pos = pos + 1
        Next i
        
        tempdf = SplitData( _
            df:=tempdf, _
            col:=1, _
            colsToFill:=Arrange(1, UBound(groupCols) + 1), _
            delimiter:="<|>", _
            skipHead:=False _
        )
        
    End If
    
    SummarizeGroup = tempdf
    
End Function



Function SwapCols(ByVal df, _
                  ByVal col1, _
                  ByVal col2)

    col1 = HeaderIndex(col1, df)
    col2 = HeaderIndex(col2, df)

    SwapCols = SwapCols_Logic(df, col1, col2)

End Function


Function SwapCols_Logic(df, col1, col2)

    Dim i
    For i = LBound(df) To UBound(df)
        Dim tempVar As Variant
        tempVar = df(i, col1)
        df(i, col1) = df(i, col2)
        df(i, col2) = tempVar
    Next i
    
    SwapCols_Logic = df
    
End Function


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



Function TrimData(ByVal df, ByVal col)

    col = HeaderIndex(col, df)

    Dim i
    For i = LBound(df) + 1 To UBound(df)
        df(i, col) = Trim(df(i, col))
    Next i

    TrimData = df

End Function



Function Unique(ByVal df, ByVal cols)
    
    cols = ScalarToArray(cols)
    cols = HeaderIndex(cols, df)

    df = Sort(df, cols)
    df = Unique_Logic(df, cols)
    
    Unique = df
        
End Function



Function ArrayToDF(arr)
    
    ReDim tempdf(1 To UBound(arr) + 1, 1 To 1)
    
    Dim i
    For i = LBound(tempdf) To UBound(tempdf)
        tempdf(i, 1) = arr(i - 1)
    Next i
    
    ArrayToDF = tempdf
    
End Function



Private Function Unique_Logic(ByVal df, ByVal cols)

    df = Concat(df, cols(0), cols, INTERNAL_SEP, False)
    df = SelectCols(df, Array(cols(0)))

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
        tempdf = SplitData( _
            df:=tempdf, _
            col:=1, _
            colsToFill:=Arrange(1, UBound(cols) + 1), _
            delimiter:=INTERNAL_SEP, _
            skipHead:=False _
        )
    End If

    Unique_Logic = tempdf

End Function



Function Unpivot(ByVal df, _
                 categoryCols, _
                 Optional attrCol = "Attribute", _
                 Optional valueCol = "Value", _
                 Optional filterBlanks = True)

    categoryCols = ScalarToArray(categoryCols)
    

    If UBound(categoryCols) > 0 Then
        ReDim Preserve df(1 To UBound(df), 1 To UBound(df, 2) + 1)
        df = Concat(df, UBound(df, 2), categoryCols, "<||>", False)
        df = DropCol(df, categoryCols)
        df = MoveCol(df, UBound(df, 2), 1)
    Else
        df = MoveCol(df, categoryCols(0), 1)
    End If

    Dim uniqDF
    uniqDF = Unique(df, 1)

    Dim finaldf
    
    Dim i
    For i = LBound(uniqDF) + 1 To UBound(uniqDF)
    
        Dim tempdf
        tempdf = Filter_Fast(df, uniqDF(i, 1), 1)
        tempdf = Transpose(tempdf)
        
        If filterBlanks Then
            tempdf = Filter(tempdf, "", 2, NotEqual)
        End If
        
        tempdf(1, 1) = attrCol
        tempdf(1, 2) = valueCol
        
        ReDim Preserve tempdf(1 To UBound(tempdf), 1 To UBound(tempdf, 2) + 1)
        tempdf(1, UBound(tempdf, 2)) = uniqDF(1, 1)
        tempdf = fillCol(tempdf, UBound(tempdf, 2), uniqDF(i, 1))

        finaldf = Stack(finaldf, tempdf)

    Next i
    
    
    If UBound(categoryCols) > 0 Then

        ReDim Preserve finaldf( _
            1 To UBound(finaldf), _
            1 To 3 + UBound(categoryCols) _
        )
        
        finaldf = SplitData(finaldf, 3, Arrange(3, UBound(categoryCols) + 1), "<||>", False)
        
        Dim pos
        pos = 1
        
        For i = 3 To UBound(finaldf, 2)
            finaldf = MoveCol_Logic(finaldf, i, 1)
        Next i
    
    Else
        finaldf = MoveCol_Logic(finaldf, 3, 1)
    End If
    

    Unpivot = finaldf

End Function




Private Function WkdayDicitonary()
    
    Set wkday = New Dictionary
    wkday.Add 1, "Sunday"
    wkday.Add 2, "Monday"
    wkday.Add 3, "Tuesday"
    wkday.Add 4, "Wednesday"
    wkday.Add 5, "Thursday"
    wkday.Add 6, "Friday"
    wkday.Add 7, "Saturday"
    
End Function



