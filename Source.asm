INCLUDE Irvine32.inc
INCLUDE Macros.inc
BUFFER_SIZE = 5000

.DATA
    localTime SYSTEMTIME <>
    WhiteTextOnBlue = white + (blue * 16)

    choice DD ?

    admin_choice DWORD ?
    UserOption DWORD ?

    buffer BYTE BUFFER_SIZE DUP(?)
    filename BYTE "Designing.txt", 0
    fileHandle HANDLE ?

    password BYTE 20 DUP(?)
    username BYTE 20 DUP(?)

    AdminUser BYTE "admin", 0
    AdminPassword BYTE "1234", 0
    AdminLogChoice DD ?

    HolderPassword BYTE 20 DUP(?)
    HolderUsername BYTE 20 DUP(?)

    StoredAccountID BYTE "22021519076", 0
    StoredPIN BYTE "2004", 0
    StoredHolderName BYTE "ALI HASSAN", 0
    StoredCNIC BYTE "35101-8888888-9", 0
    StoredNO BYTE "03008888888", 0
    StoredCity BYTE "KHARIAN"
    StoredMail BYTE "alihassan@example.com", 0
    gender BYTE "M", 0
    StoredAmount        DWORD 2000, 

    HolderLogChoice DD ?
    
    fcash DWORD ?
    fcashChoice DWORD ?

    wdcash DWORD ?
    wdcashChoice DWORD ?

    depositAmount DWORD ?
    TransferMoney DWORD ?
    GenerateBalance DWORD 0


.CODE

AddColor PROC
    MOV EAX, WhiteTextOnBlue
    CALL SetTextColor
    CALL CLRSCR
    RET
AddColor ENDP


Time PROC
    INVOKE GetLocalTime, ADDR localTime
    movzx EAX, localTime.wHour
    CALL WriteDec
    mWrite ":"
    movzx EAX, localTime.wMinute
    CALL WriteDec
    mWrite ":"
    movzx EAX, localTime.wSecond
    CALL WriteDec
	mWrite "                                                                       "
    movzx EAX, localTime.wDay
    CALL WriteDec
    mWrite "/"
    movzx EAX, localTime.wMonth
    CALL WriteDec
    mWrite "/"
    movzx EAX, localTime.wYear
    CALL WriteDec
	CALL CRLF
    CALL CRLF
    RET
Time ENDP


Design PROC
	; Open the file for input.
	MOV EDX,OFFSET filename
	CALL OpenInputFile
	MOV fileHandle,EAX
	; Check for errors.
	CMP EAX,INVALID_HANDLE_VALUE ; error opening file?
	jne file_ok ; no: skip
	mWrite <"Cannot open file",0dh,0ah>
	JMP quit ; and quit
	file_ok:
	; Read the file into a buffer.
	MOV EDX,OFFSET buffer
	MOV ECX,BUFFER_SIZE
	CALL ReadFromFile
	jnc check_buffer_size ; error reading?
	mWrite "Error reading file. " ; yes: show error message
	CALL WriteWindowsMsg
	JMP close_file
	check_buffer_size:
	CMP EAX,BUFFER_SIZE ; buffer large enough?
	jb buf_size_ok ; yes
	mWrite <"Error: Buffer too small for the file",0dh,0ah>
	JMP quit ; and quit
	buf_size_ok:
	MOV buffer[EAX],0 ; insert null terminator
	;mWrite "File size: "
	;CALL WriteDec ; display file size
	; Display the buffer.
	mWrite <0dh,0ah,0dh,0ah>
	MOV EDX,OFFSET buffer ; display the buffer
	CALL WriteString
	CALL CRLF
	close_file:
	MOV EAX,fileHandle
	CALL CloseFile
quit:
    CALL CRLF
	RET
Design ENDP

FrontPage PROC
   CALL CRLF
   CALL CRLF
   mWrite "                    UNIVERSITY OF GUJRAT, HAFIZ HAYAT CAMPUS"
   CALL CRLF
   mWrite "                               Sec(A) BSCS III"
   CALL CRLF
   CALL CRLF
   CALL CRLF
   mWrite "                 COMPUTER ORGANIZATION & ASSEMBLY LANGUAGE : CS(255)"
   CALL CRLF
   CALL CRLF
   CALL CRLF
   mWrite "                      MINI-PROJECT  : ATM BANK SIMULATOR"
   CALL CRLF
   CALL CRLF
   mWrite "                              Batch : 22TH"
   CALL CRLF
   CALL CRLF
   CALL CRLF
   CALL CRLF
   CALL CRLF
   mWrite "                      DevelopedBy : "
   CALL CRLF
   CALL CRLF
   mWrite "                      ALI HASSAN         : 22021519-076"
   CALL CRLF
   CALL CRLF
   mWrite "                        LAIBA JAVEED  : 22021519-074"
   CALL CRLF
   CALL CRLF
   mWrite "                          NOSHEEN : 22021519-004"
   CALL CRLF
   CALL CRLF
   mWrite "                     SAMIA MAHEEN         : 22021519-022"
    MOV EAX, 4000
    CALL delay
    CALL CLRSCR
    RET
FrontPage ENDP

AdminLoginFUNC PROC
    l1:
    CALL CLRSCR
    MOV EAX, 0
    MOV EBX, 0
    MOV ECX, 0
    INVOKE Design
    mWrite "         [ ---------------- << LOGIN  INTERFACE >> ---------------- ]"
    CALL CRLF
    CALL CRLF

    mWrite "        "
    mWrite " Enter Administrator Username: "
    MOV ECX, 20  ; Set the correct size of the username buffer

    MOV EDX, OFFSET username
    CALL readstring ; Input username
    mWrite "        "
    mWrite " Enter Yours Password: "

    MOV ECX, 20  ; Set the correct size of the password buffer

    MOV EDX, OFFSET password
    CALL readstring ; Input password

    CALL CRLF

    MOV EDI, OFFSET username
    MOV ESI, OFFSET AdminUser
    CMPSB
    JE s1
    mWrite "        "
    mWrite "[-] ERROR! Username or password is incorrect, please try again... "
    CALL CRLF
    mWrite "        "
    CALL WAITMSG
    CALL CRLF
    JMP l1

    s1:
    MOV ESI, OFFSET password
    MOV EDI, OFFSET AdminPassword
    CMPSB
    JE s2
    mWrite "        "
    mWrite " [-] ERROR! Username or password is incorrect, please try again... "
    CALL CRLF
     mWrite "         Do you want to try again? (1 = Yes, 0 = No): "
    CALL Readint
    MOV AdminLogChoice, EAX
	CALL CLRSCR
    CMP AdminLogChoice, 1
    JE l1  ; User wants to try again

    JMP end_it
  

    s2:
    mWrite "        "
    mWrite " [+] <<|>> Checking Admin Credentials!!! <<|>> [+]"

    CALL CRLF
     MOV EAX, 4000
    CALL delay
    CALL AdminOperation
    end_it:
    RET
AdminLoginFUNC ENDP

AdminOperation PROC
        CALL CRLF
        CALL CRLF
        mWrite "        Admin Login Successful!"
   
        CALL CRLF
        CALL CRLF
        CALL CRLF
        mWrite "        "
        CALL WAITMSG
        CALL CLRSCR

        Back:
        mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Welcome Administrator _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
        CALL CRLF
        CALL CRLF
        mWrite "			  Please select your choice : :"
        CALL CRLF
        CALL CRLF
        mWrite "			  [1] Search User Detail"        
        CALL CRLF
        CALL CRLF
        mWrite "			  [2] ATM INFO"     
        CALL CRLF
        CALL CRLF
        mWrite "			  [3] Start Atm"  
        CALL CRLF
        CALL CRLF
        mWrite "			  [4] Turn OFF the System "  
        CALL CRLF
        CALL CRLF
      

        mWrite "			  Your choice: "
        CALL ReadDec
        JMP AdmOP
        CALL CRLF
        mWrite "			  "
        JMP ExitAdminOperation

AdmOP:
    CMP EAX, 1
    JE SearchUserDetail
    CMP EAX, 2
    JE ATMINFO
    CMP EAX, 3
    JE StartAtm
    CMP EAX, 4
    JE TurnOFFtheSystem
   


    JMP InvalidChoice

SearchUserDetail:
 CALL CLRSCR
    CALL CRLF
    CALL CRLF
    mWrite "        Account Details"
    CALL CRLF
    mWrite "        Enter Account Number you want to find Details :--> Single User Exist!!!"
    CALL CRLF
    CALL CRLF
    mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Account Holder Information & Detail _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
    CALL CRLF
    CALL CRLF
    mWrite "			  Account Number:                 "
    mov EDX, OFFSET StoredAccountID
    CALL WriteString
    CALL CRLF
    mWrite "			  Holder Name:                    "
    mov EDX, OFFSET StoredHolderName
    CALL WriteString
    CALL CRLF
    mWrite "			  Current Balance:                "
    mov EAX, StoredAmount
    CALL WriteDec
    CALL CRLF
    mWrite "			  Personal Identification Number: "
    mov EDX, OFFSET StoredPIN
    CALL WriteString
    CALL CRLF
    mWrite "			  ID Card Number:                 "
    mov EDX, OFFSET StoredCNIC
    CALL WriteString
    CALL CRLF
    mWrite "			  Contact Number:                 "
    mov EDX, OFFSET StoredNO
    CALL WriteString
    CALL CRLF
    mWrite "			  Address City:                   "
    mov EDX, OFFSET StoredCity
    CALL WriteString
    CALL CRLF
    mWrite "			  E-Mail Address:                 "
    mov EDX, OFFSET StoredMail
    CALL WriteString
    CALL CRLF
    mWrite "			  Gender:                         "
    mov EDX, OFFSET gender
    CALL WriteString
    CALL CRLF
    mWrite "			  "
    CALL WAITMSG
    CALL CLRSCR
    JMP ExitAdminOperation

ATMINFO:
    CALL CLRSCR
    CALL CRLF
    CALL CRLF
    mWrite "        ATM Info:"
    CALL CRLF
    mWrite "        ----------------------"
    CALL CRLF
    mWrite "        Bank : JPMorgan Chase Bank"
    CALL CRLF
    mWrite "        Branch Code : Kharian Branch [1264]"
    CALL CRLF
    mWrite "        Model: ABC-1234"
    CALL CRLF
    mWrite "        Serial No: S12345678"
    CALL CRLF
    mWrite "        Available Cash: "
    CALL CRLF
    mWrite "        Year: 2024"
    CALL CRLF
    CALL CRLF
    mWrite "        "
    CALL WAITMSG
    CALL CLRSCR
    JMP ExitAdminOperation

StartAtm:
    CALL CLRSCR
    CALL CRLF
    CALL CRLF
    mWrite "       Starting System..."
    CALL CRLF
    CALL CRLF
    mWrite "        HI :)"
    CALL CRLF
    CALL CRLF
    mWrite "        "
    CALL WAITMSG
    CALL HolderLoginFUNC
    JMP ExitAdminOperation

TurnOFFtheSystem:
    CALL CLRSCR
    CALL CRLF
    mWrite "        Good Bye Admin..."
    CALL CRLF
    CALL CRLF
    mWrite "        Have a Nice Day :)"
    CALL CRLF
    mWrite "        "
    CALL WAITMSG
    INVOKE EXITPROCESS, 0


InvalidChoice:
    CALL CLRSCR
    JMP AdminOperation

ExitAdminOperation:
    JMP Back
    RET
AdminOperation ENDP


UserOperations PROC
   
    mWrite "         Account Holder Login Account Found!"
    CALL CRLF
    CALL CRLF
    CALL CRLF
    mWrite "         "
    CALL WAITMSG
    CALL CLRSCR

Back:
    mWrite "        Welcome User "
    CALL CRLF
    mWrite "        Enter your choice : "
    CALL CRLF
    CALL CRLF
    mWrite "			  [1] Fast Cash"
    CALL CRLF
    CALL CRLF
    mWrite "			  [2] Cash Withdrawal"
    CALL CRLF
    CALL CRLF
    mWrite "			  [3] Deposit"
    CALL CRLF
    CALL CRLF
    mWrite "			  [4] Transactions "
    CALL CRLF
    CALL CRLF
    mWrite "			  [5] Account Detail"
    CALL CRLF
    CALL CRLF
    mWrite "			  [6] Change PIN "
    CALL CRLF
    CALL CRLF
    mWrite "			  [7] Update Account INFO "
    CALL CRLF
    CALL CRLF
    mWrite "			  [8] Generate Receipt"
    CALL CRLF
    CALL CRLF
    mWrite "			  [9] Log out"
    CALL CRLF
    CALL CRLF
    CALL CRLF
    mWrite "			  [->] Your Choice : "
    CALL ReadInt
    MOV UserOption, EAX

    CMP UserOption, 1
    JE FastCash

    CMP UserOption, 2
    JE CashWithdrawal

    CMP UserOption, 3
    JE Deposit

    CMP UserOption, 4
    JE Transactions

    CMP UserOption, 5
    JE AccountDetail

    CMP UserOption, 6
    JE ChangePIN

    CMP UserOption, 7
    JE UpdateAccountInfo

    CMP UserOption, 8
    JE GenerateReceipt

    CMP UserOption, 9
    JE LogOut

    mWrite "        Invalid Choice..."
    CALL WAITMSG
    CALL CLRSCR
    JMP Back

    FastCash:
        CALL CLRSCR
        CALL QuickCash
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        JMP Back

    CashWithdrawal:
        CALL CLRSCR
        CALL WithdrawalCash
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        JMP Back

    Deposit:
        CALL CLRSCR
        CALL DepositCash
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        JMP Back

    Transactions:
        CALL CLRSCR
        CALL TransferAmount
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        JMP Back

    AccountDetail:
        CALL CLRSCR
        CALL AccountINFO
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        JMP Back

    ChangePIN:
        CALL CLRSCR
        CALL ChangeUserPIN
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        JMP Back

    UpdateAccountInfo:
        CALL CLRSCR
        CALL UpdateINFO
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        JMP Back

    GenerateReceipt:
        CALL CLRSCR
        CALL GenerateTransactionReceipt
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        JMP Back

    LogOut:
        CALL CLRSCR
        INVOKE Design
        mWrite "			  THANKS FOR VISITING :)"
        CALL CRLF
        CALL CRLF
        mWrite "			  Logged Out Successfully!!!"
        CALL CRLF
        mWrite "			  "
        CALL WAITMSG
        CALL CLRSCR
        CALL LoggedOut
UserOperations ENDP

HolderLoginFUNC PROC
    l1:
    CALL CLRSCR
    INVOKE Design
    MOV EAX, 0
    MOV EBX, 0
    MOV ECX, 0
    mWrite "         [ ---------------- << LOGIN  INTERFACE >> ---------------- ]"
    CALL CRLF
    CALL CRLF

    mWrite "        "
    mWrite " Enter Account Number: "
    MOV ECX, 20

    MOV EDX, OFFSET HolderUsername
    CALL readstring 
    mWrite "        "

    mWrite " Enter Yours PIN: "
    MOV ECX, 20
    MOV EDX, OFFSET HolderPassword
    CALL readstring

    CALL CRLF

    MOV EDI, OFFSET HolderUsername
    MOV ESI, OFFSET StoredAccountID
    CMPSB
    JE s1
    mWrite "        "
    mWrite "[-] ERROR! HolderUsername or HolderPassword is incorrect, please try again... "
    CALL CRLF
    mWrite "        "
    CALL WAITMSG
    CALL CRLF
    JMP l1

    s1:
    MOV ESI, OFFSET HolderPassword
    MOV EDI, OFFSET StoredPIN
    CMPSB
    JE s2
    mWrite "        "
    mWrite " [-] ERROR! HolderUsername or HolderPassword is incorrect, please try again... "
    CALL CRLF
     mWrite "         Do you want to try again? (1 = Yes, 0 = No): "
    CALL Readint
    MOV HolderLogChoice, EAX
	CALL CLRSCR
    CMP HolderLogChoice, 1
    JE l1  ; User wants to try again

    JMP end_it
  

    s2:
    mWrite "        "
    mWrite " [+] <<|>> Checking Entered Credentials...!!! <<|>> [+]"

    CALL CRLF
    MOV EAX, 4000
    CALL delay
    INVOKE UserOperations
    end_it:
    RET
HolderLoginFUNC ENDP




QuickCash PROC
    mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Account Holder Information & Detail _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
    CALL CRLF
    mWrite "			  Account Number: "
    MOV EDX, OFFSET StoredAccountID
    CALL WriteString
    CALL CRLF
    CALL CRLF
    mWrite "			  Current Balance: "
    MOV EAX, StoredAmount
    CALL WriteDec
    CALL CRLF
    CALL CRLF
    CALL CRLF

    ; Check balance for Quick Cash
    .if (StoredAmount > 500)
        mWrite "			  Please select the Withdrawal amount:"
        CALL CRLF
        CALL CRLF
        mWrite "			  1. Rs. 500"        
        CALL CRLF
        CALL CRLF
        mWrite "			  2. Rs. 1000 "     
        CALL CRLF
        CALL CRLF
        mWrite "			  3. Rs. 1500 "  
        CALL CRLF
        CALL CRLF
        mWrite "			  4. Rs. 2000 "  
        CALL CRLF
        CALL CRLF
        mWrite "			  5. Rs. 2500 "  
        CALL CRLF
        CALL CRLF
        mWrite "			  6. Rs. 3000 "  
        CALL CRLF
        CALL CRLF 
        mWrite "			  Your choice: "
        CALL ReadDec
        MOV fcashChoice, EAX ; Store user's choice in fcashChoice
        JMP FastCash
    .else 
        mWrite "			  Your balance does not meet the minimum requirement for Quick Cash."
        CALL CRLF
        mWrite "			  "
        JMP EndQuickCash
    .endif

FastCash:
    ; Assuming fcashChoice is in EAX
    CMP EAX, 1
    JE Withdraw500
    CMP EAX, 2
    JE Withdraw1000
    CMP EAX, 3
    JE Withdraw1500
    CMP EAX, 4
    JE Withdraw2000
    CMP EAX, 5
    JE Withdraw2500
    CMP EAX, 6
    JE Withdraw3000

    ; Default case (if fcashChoice is not 1-6)
    JMP InvalidChoice

Withdraw500:
    CMP StoredAmount, 500
    JL InsufficientBalance
    SUB StoredAmount, 500
    mWrite "			  Processing withdrawal of Rs. 500..."
    MOV EAX, 4000
    ADD GenerateBalance, 500  
    CALL delay
    JMP DoneWithdrawal

Withdraw1000:
    CMP StoredAmount, 1000
    JL InsufficientBalance
    SUB StoredAmount, 1000
    mWrite "			  Processing withdrawal of Rs. 1000..."
    MOV EAX, 4000
    ADD GenerateBalance, 1000
    CALL delay
    JMP DoneWithdrawal

Withdraw1500:
    CMP StoredAmount, 1500
    JL InsufficientBalance
    SUB StoredAmount, 1500
    mWrite "			  Processing withdrawal of Rs. 1500..."
    MOV EAX, 4000
    ADD GenerateBalance, 1500
    CALL delay
    JMP DoneWithdrawal

Withdraw2000:
    CMP StoredAmount, 2000
    JL InsufficientBalance
    SUB StoredAmount, 2000
    mWrite "			  Processing withdrawal of Rs. 2000..."
    MOV EAX, 4000
    ADD GenerateBalance, 2000
    CALL delay
    JMP DoneWithdrawal

Withdraw2500:
    CMP StoredAmount, 2500
    JL InsufficientBalance
    SUB StoredAmount, 2500
    mWrite "			  Processing withdrawal of Rs. 2500..."
    MOV EAX, 4000
    ADD GenerateBalance, 2500
    CALL delay
    JMP DoneWithdrawal

Withdraw3000:
    CMP StoredAmount, 3000
    JL InsufficientBalance
    SUB StoredAmount, 3000
    mWrite "			  Processing withdrawal of Rs. 3000..."
    MOV EAX, 4000
    ADD GenerateBalance, 3000
    CALL delay
    JMP DoneWithdrawal

InsufficientBalance:
    mWrite "			  Insufficient balance. Try another amount."
    CALL CRLF
    mWrite "			  "
    CALL WAITMSG
    CALL CLRSCR
    JMP QuickCash

InvalidChoice:
    CALL CLRSCR
    JMP QuickCash

DoneWithdrawal:
    CALL CRLF
    CALL CRLF 
    mWrite "			  Remaining Balance : "      
    MOV EAX, StoredAmount
    CALL WriteDec
    JMP EndQuickCash

EndQuickCash:
    RET
QuickCash ENDP

WithdrawalCash PROC
    mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Account Holder Information & Detail _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
    CALL CRLF
    mWrite "			  Account Number: "
    MOV EDX, OFFSET StoredAccountID
    CALL WriteString
    CALL CRLF
    CALL CRLF
    mWrite "			  Current Balance: "
    MOV EAX, StoredAmount
    CALL WriteDec
    CALL CRLF
    CALL CRLF
    CALL CRLF

    ; Check balance for Withdraw Cash
    .if (StoredAmount > 500)
        mWrite "			  Please select the Withdrawal amount:"
        CALL CRLF
        CALL CRLF
        mWrite "			  1. Rs. 200"        
        CALL CRLF
        CALL CRLF
        mWrite "			  2. Rs. 500 "     
        CALL CRLF
        CALL CRLF
        mWrite "			  3. Rs. 700 "  
        CALL CRLF
        CALL CRLF
        mWrite "			  4. Other Amount "  
        CALL CRLF
        CALL CRLF
       
        mWrite "			  Your choice: "
        CALL ReadDec
        MOV wdcashChoice, EAX ; Store user's choice in wdcashChoice
        JMP FastCash
    .else 
        mWrite "			  Your balance does not meet the minimum requirement for Withdrawal Cash."
        CALL CRLF
        mWrite "			  "
        JMP EndWithdraw
    .endif

FastCash:
    ; Assuming wdcashChoice is in EAX
    CMP EAX, 1
    JE Withdraw200
    CMP EAX, 2
    JE Withdraw500
    CMP EAX, 3
    JE Withdraw700
    CMP EAX, 4
    JE WithdrawOtherAmount


    ; Default case (if wdcashChoice is not 1-4)
    JMP InvalidChoice

Withdraw200:
    CMP StoredAmount, 200
    JL InsufficientBalance
    SUB StoredAmount, 200
    mWrite "			  Processing withdrawal of Rs. 200..."
    MOV EAX, 4000
    ADD GenerateBalance, 200
    CALL delay
    JMP DoneWithdrawal

Withdraw500:
    CMP StoredAmount, 500
    JL InsufficientBalance
    SUB StoredAmount, 500
    mWrite "			  Processing withdrawal of Rs. 500..."
    MOV EAX, 4000
    ADD GenerateBalance, 500
    CALL delay
    JMP DoneWithdrawal

Withdraw700:
    CMP StoredAmount, 700
    JL InsufficientBalance
    SUB StoredAmount, 700
    mWrite "			  Processing withdrawal of Rs. 700..."
    MOV EAX, 4000
    ADD GenerateBalance, 700
    CALL delay
    JMP DoneWithdrawal

WithdrawOtherAmount:
    CALL CRLF
    mWrite "			  Enter the Amount You want to Withdraw : "
    CALL ReadInt
    CMP StoredAmount, EAX
    JL InsufficientBalance
    SUB StoredAmount, EAX
    mWrite "			  Processing withdrawal of Enterened Amount..."
    ADD GenerateBalance, EAX
    MOV EAX, 4000
    CALL delay
    JMP DoneWithdrawal


InsufficientBalance:
    mWrite "			  Insufficient balance. Try another amount."
    CALL CRLF
    mWrite "			  "
    CALL WAITMSG
    CALL CLRSCR
    JMP WithdrawalCash

InvalidChoice:
    CALL CLRSCR
    JMP WithdrawalCash

DoneWithdrawal:
    CALL CRLF
    CALL CRLF 
    mWrite "			  Remaining Balance : "      
    MOV EAX, StoredAmount
    CALL WriteDec
    JMP EndWithdraw

EndWithdraw:
    RET
WithdrawalCash ENDP

DepositCash PROC
    mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Account Holder Information & Detail _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
    CALL CRLF
    mWrite "			  Account Number: "
    MOV EDX, OFFSET StoredAccountID
    CALL WriteString
    CALL CRLF
    CALL CRLF
    mWrite "			  Current Balance: "
    MOV EAX, StoredAmount
    CALL WriteDec
    CALL CRLF
    CALL CRLF
    CALL CRLF

    mWrite "			  Please put the amount in the Deposit box : Rs. "
    CALL ReadDec
    MOV depositAmount, EAX ; Assuming depositAmount is a variable to store the deposit amount

    ; Check if deposit amount is invalid
    CMP depositAmount, 0
    jle InvalidDepositAmount

    mWrite "			  Processing deposit of Rs. "
    MOV EAX, depositAmount
    CALL WriteDec
    mWrite "..."
    
    ; Process deposit
    ADD StoredAmount, EAX ; Assuming StoredAmount is a variable representing the balance
    CALL CRLF
    mWrite "			  Your New Balance is: "
    MOV EAX, StoredAmount
    CALL WriteDec
    mWrite " Rs"
    CALL CRLF

    RET

InvalidDepositAmount:
    mWrite "			  Invalid Deposit Amount. Please try again."
    CALL CRLF
    mWrite "			  "
    CALL WAITMSG
    CALL CLRSCR
    ; Jump back to get a valid deposit amount
    JMP DepositCash
    
    RET
DepositCash ENDP

TransferAmount PROC
    ; Display account information
    mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Account Holder Information & Detail _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
    CALL CRLF
    mWrite "			  Account Number: "
    mov EDX, OFFSET StoredAccountID
    CALL WriteString
    CALL CRLF
    CALL CRLF
    mWrite "			  Current Balance: "
    mov EAX, StoredAmount
    CALL WriteDec
    CALL CRLF
    CALL CRLF
    CALL CRLF

    ; Prompt for account number
    mWrite "			  Please Enter the Account Number you want to Send Money (11 Digits): "
    CALL ReadDec

    ; Loop for entering a valid transfer amount
EnterTransferAmount:
    ; Prompt for transfer amount
    mWrite "			  Please Enter the Transaction Amount: Rs. "
    CALL ReadDec
    mov TransferMoney, EAX
    ADD GenerateBalance, EAX

    ; Check for invalid transfer amount
    CMP EAX, 0
    jle InvalidTransferAmount
    CMP EAX, StoredAmount
    jg InvalidTransferAmount

    ; Process the transaction
    mWrite "			  Processing Transaction of Rs. "
    mov EAX, TransferMoney
    CALL WriteDec
    mWrite "..."
    SUB StoredAmount, EAX
    CALL CRLF
    CALL CRLF
    ; Display new balance
    mWrite "			  Your New Balance is: "
    mov EAX, StoredAmount
    CALL WriteDec
    mWrite " Rs"
    CALL CRLF
    JMP EndTransferAmount

InvalidTransferAmount:
    ; Display error message for invalid transfer amount
    mWrite "			  Invalid Transfer Amount. Please try again."
    CALL CRLF
    mWrite "			  "
    CALL WAITMSG
    CALL CLRSCR
    JMP EnterTransferAmount

EndTransferAmount:
    RET
TransferAmount ENDP

AccountINFO PROC
    ; Display account information
    mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Account Holder Information & Detail _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
    CALL CRLF
    CALL CRLF
    mWrite "			  Account Number:                 "
    mov EDX, OFFSET StoredAccountID
    CALL WriteString
    CALL CRLF
    mWrite "			  Holder Name:                    "
    mov EDX, OFFSET StoredHolderName
    CALL WriteString
    CALL CRLF
    mWrite "			  Current Balance:                "
    mov EAX, StoredAmount
    CALL WriteDec
    CALL CRLF
    mWrite "			  Personal Identification Number: "
    mov EDX, OFFSET StoredPIN
    CALL WriteString
    CALL CRLF
    mWrite "			  ID Card Number:                 "
    mov EDX, OFFSET StoredCNIC
    CALL WriteString
    CALL CRLF
    mWrite "			  Contact Number:                 "
    mov EDX, OFFSET StoredNO
    CALL WriteString
    CALL CRLF
    mWrite "			  Address City:                   "
    mov EDX, OFFSET StoredCity
    CALL WriteString
    CALL CRLF
    mWrite "			  E-Mail Address:                 "
    mov EDX, OFFSET StoredMail
    CALL WriteString
    CALL CRLF
    mWrite "			  Gender:                         "
    mov EDX, OFFSET gender
    CALL WriteString
   
    RET
AccountINFO ENDP

ChangeUserPIN PROC
    mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Account Holder Information & Detail _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
    CALL CRLF
    CALL CRLF
    mWrite "			  Enter New Personal Identification Number(PIN) :"
    mov EDX,OFFSET StoredPIN ; point to the buffer
    mov ECX,SIZEOF StoredPIN ; specify max characters
    CALL ReadString ; input the string
    CALL CRLF
    CALL CRLF
    mWrite "			  Personal Identification Number(PIN) Successfully changed to "
    mov EDX,OFFSET StoredPIN
    CALL WriteString

    RET
ChangeUserPIN ENDP

UpdateINFO PROC
        mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Account Holder Information & Detail _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
        CALL CRLF
        CALL CRLF
        mWrite "			  Please select the Info you want to Change :"
        CALL CRLF
        CALL CRLF
        mWrite "			  1. Your Name"        
        CALL CRLF
        CALL CRLF
        mWrite "			  2. Your Phone No. "     
        CALL CRLF
        CALL CRLF
        mWrite "			  3. Your Address "  
        CALL CRLF
        CALL CRLF
        mWrite "			  4. Your MAIL "  
        CALL CRLF
        CALL CRLF
        mWrite "			  5. Your Gender "  
        CALL CRLF
        CALL CRLF

        mWrite "			  Your choice: "
        CALL ReadDec
        JMP InfoJMP
        CALL CRLF
        mWrite "			  "
        JMP ExitUpdation

InfoJMP:
    CMP EAX, 1
    JE YourName
    CMP EAX, 2
    JE YourPhoneNo
    CMP EAX, 3
    JE YourAddress
    CMP EAX, 4
    JE YourMAIL
    CMP EAX, 5
    JE YourGender


    JMP InvalidChoice

YourName:
     mWrite "			  Enter New User Name :"
    MOV EDX,OFFSET StoredHolderName ; point to the buffer
    MOV ECX,SIZEOF StoredHolderName ; specify max characters
    CALL ReadString ; input the string
    CALL CRLF
    CALL CRLF
    mWrite "			  User Name changed to "
    MOV EDX,OFFSET StoredHolderName
    CALL WriteString
    JMP ExitUpdation

YourPhoneNo:
     mWrite "			  Enter New Phone no :"
    MOV EDX,OFFSET StoredNO ; point to the buffer
    MOV ECX,SIZEOF StoredNO ; specify max characters
    CALL ReadString ; input the string
    CALL CRLF
    CALL CRLF
    mWrite "			  Phone no Successfully changed to "
    MOV EDX,OFFSET StoredNO
    CALL WriteString
    JMP ExitUpdation

YourAddress:
     mWrite "			  Enter New Address :"
    MOV EDX,OFFSET StoredCity ; point to the buffer
    MOV ECX,SIZEOF StoredCity ; specify max characters
    CALL ReadString ; input the string
    CALL CRLF
    CALL CRLF
    mWrite "			  Address Successfully changed to "
    MOV EDX,OFFSET StoredCity
    CALL WriteString
    JMP ExitUpdation

YourMAIL:
     mWrite "			  Enter Your MAIL :"
    MOV EDX,OFFSET StoredMail ; point to the buffer
    MOV ECX,SIZEOF StoredMail ; specify max characters
    CALL ReadString ; input the string
    CALL CRLF
    CALL CRLF
    mWrite "			  Your MAIL Successfully changed to "
    MOV EDX,OFFSET StoredMail
    CALL WriteString
    JMP ExitUpdation

YourGender:
    mWrite "			  Enter Gender (F/M/O):"
    MOV EDX,OFFSET gender ; point to the buffer
    MOV ECX,SIZEOF gender ; specify max characters
    CALL ReadString ; input the string
    CALL CRLF
    CALL CRLF
    mWrite "			  Gender Successfully changed to "
    MOV EDX,OFFSET gender
    CALL WriteString
    JMP ExitUpdation

InvalidChoice:
    CALL CLRSCR
    JMP UpdateINFO

ExitUpdation:
    RET
UpdateINFO ENDP

GenerateTransactionReceipt PROC
    mWrite "*_ * _ * _ * _ * _ * _ * _ * _ * _ * _ Transaction Receipt _ * _ * _ * _ * _ * _ * _ * _ * _ * _*"
    CALL CRLF
    CALL CRLF

    .if (GenerateBalance > 0)
            mWrite "			  Account Number:                 "
            mov EDX, OFFSET StoredAccountID
            CALL WriteString
            CALL CRLF
            mWrite "			  Holder Name:                    "
            mov EDX, OFFSET StoredHolderName
            CALL WriteString
            CALL CRLF
            mWrite "			  Remaining Balance:              "
            mov EAX, StoredAmount
            CALL WriteDec
            CALL CRLF
             mWrite "			  Transaction of Rs :             "
            mov EAX, GenerateBalance
            CALL WriteDec
            CALL CRLF
            mWrite "			  Contact Number:                 "
            mov EDX, OFFSET StoredNO
            CALL WriteString
            CALL CRLF
            mWrite "			  Address City:                   "
            mov EDX, OFFSET StoredCity
            CALL WriteString
            CALL CRLF
            mWrite "			  E-Mail Address:                 "
            mov EDX, OFFSET StoredMail
            CALL WriteString
        .else 
            mWrite "			  Please Perform any Transaction to generate Receipt!!!"
            CALL CRLF
            mWrite "			  "
            CALL WAITMSG
    .endif

    RET
GenerateTransactionReceipt ENDP

LoggedOut PROC
    CALL HolderLoginFUNC
    RET
LoggedOut ENDP


main PROC				
    INVOKE AddColor
    INVOKE FrontPage
    INVOKE Time
    INVOKE Design
	
    mWrite "			  Please INSERT your Card [Press any Key to insert card]"
	CALL CRLF
	CALL CRLF
	
	mWrite "		  	  "
	CALL WAITMSG
	CALL CLRSCR

	try_again:
    INVOKE Design
	CALL CRLF
	mWrite "			  LOG IN:"
	CALL CRLF
	CALL CRLF
	mWrite "			  [1] Administrator"
	CALL CRLF
	CALL CRLF
	mWrite "			  [2] Account Holder"
	CALL CRLF
	CALL CRLF
	mWrite "			  [3] EXIT"
	CALL CRLF
	CALL CRLF
	mWrite "			  [->] YOUR CHOICE : "
	CALL readint
	MOV choice, EAX

    CMP choice, 1
    JE case_1
    CMP choice, 2
    JE case_2
    CMP choice, 3
    JE case_3
   
    CALL CRLF
    mWrite "			  Invalid choice!"
    CALL CRLF

    mWrite "			  Do you want to try again? (1 = Yes, 0 = No): "
    CALL Readint
    MOV choice, EAX
	CALL CLRSCR
    CMP choice, 1
    JE try_again  ; User wants to try again

    JMP end_it

case_1:
    INVOKE AdminLoginFUNC
    JMP end_it

case_2:
    CALL CLRSCR
    CALL HolderLoginFUNC
    JMP end_it

case_3:
    EXIT

end_it:

	CALL CRLF
	CALL CRLF
    INVOKE EXITPROCESS, 0
main ENDP

END MAIN