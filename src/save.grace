import "sys" as sys
import "io" as io
import "curl" as curl


var imported := []
var verbose := false
parseArgs

method parseArgs{
    var args := sys.argv
    if(args.size > 4)then{
        displayHelp
    }
    if ((args.size > 2)) then {
        match(args[2])
        case {"-get" -> print("Locating main package file"); doGet(args[3]);}
        case {_ -> displayHelp}
    }
    if ((args.size > 3)) then{
        if (args[3] == "-verbose")then{
            verbose := true
        }
    }
    else{
        displayHelp;
    }
}

method doGet(impAddress){
    var file := object{
        var address : String is public
        var data : String is public  
    }
    file.address := impAddress
    if (impAddress.substringFrom(impAddress.size-5)to(impAddress.size) == ".grace")then{
        if (getUrl(file)) then { 
            if (writeAndCompile(file))then{
                parseFile(file);
            }
        }
    }
    else{ 
        print("Invalid url. Url must refer to a .grace file");
        return
    }
}

method getUrl(file){
    if (!waitForRequest(file, "http://"))then{
        if (!waitForRequest(file, "http://"))then{
            print("Could not locate import: "++file.address); 
            return false;
        }
    }
    return true;
}

method waitForRequest(file, prefix : String) -> Boolean{
    var startTime := sys.cputime
    var performed := false
    var received := false
    var req := curl.easy
    req.url := prefix++file.address;
    print("Searching for import: "++prefix++file.address);
    while{((sys.cputime - startTime) < 3) && (!received)}do{
        if (!performed)then{
            print(" Connecting...")
            req.onReceive {d->
                file.data := d.decode("utf-8")
                received:= true
                print(" Response received")
            }
            req.perform
            performed := true
        }
    }
    if(req.responseCode != 200)then{
        print(" Invalid address: "++req.responseCode)
        return false
    }
    received
}

method validateFile(file) -> Boolean{
    if ((file.data.size)>1)then{
        if(file.data[1]=="<")then{
            print(" Not a valid grace file");
            return false
        }
    }
    return true
}

method writeAndCompile(file) -> Boolean{
    if (!validateFile(file))then{
        return false;
    }
    var usrDir := "/usr/lib/packages/"
    //createDirectory(usrDir++file.address)
    file = file.open(usrDir++file.address)
    var toWrite := io.open(usrDir++file.address, "w")
    toWrite.write(file.data);
    toWrite.close;
    return true;
 }

method createDirectory(address){
    print("createDir");
    var toMake := ""
    var nextPath := "" 
    var count := 1
    while{count < address.size} do {
        nextPath := nextPath ++ address[count]
        if(address[count] == "/")then{
            toMake := toMake ++ nextPath 
            nextPath := ""   
        }
        count := count+1;
    }
    print("making "++toMake)
    if (!io.exists(toMake))then{
        io.system("mkdir -p "++toMake)
    }
}

method searchForImports{
    parseFile()
}

method parseFile(file){
    var data := file.data
    var curPos := 1;
    var startPos := curPos;
    while{curPos <= data.size}do{
        startPos := curPos
        while {(curPos <= data.size) && (data[curPos] != "\n")}do{
            curPos := curPos+1;
        }
        var line := data.substringFrom(startPos)to(curPos-1)
        if (!processLine(line))then{
            return true
        }
        curPos := curPos + 1
    }
}

method processLine(line) -> Boolean {
    print (line)
    print (line.substringFrom(1)to(7))   
    print("-get [url] to fetch a package located at a given url")
    if (line.size > 1)then{
        if (line[1] == "#")then{ 
            return true
        }
        elseif ((line.size > 2) && (line.substringFrom(1)to(2) == "//"))then{
            return true;
        }
        elseif ((line.size > 6) && (line.substringFrom(1)to(7) == "import "))then{
            parseImport(line.substringFrom(8)to(line.size));
            return true

        }
        elseif ((line.size > 7) && (line.substringFrom(1)to(8) == "dialect "))then{
            return true;
        }
    }
    return false
}

method parseImport(line){
    var curPos := 1
    var startPos := curPos
    var nextImport := ""
    while{(curPos <= line.size) && (line[curPos] != " ")}do{
        curPos := curPos + 1
    }
    nextImport := line.substringFrom(startPos)to(curPos)
    while {(curPos <= line.size) && (line[curPos] == " ")}do{
        curPos := curPos + 1
    }
    if (!(curPos >= line.size))then{
        print("Invalid import : "++nextImport);
    }
    elseif (!imported.contains(nextImport))then{   
        print("next import = "++nextImport)
        imported.push(nextImport)
        doGet(nextImport)
    }
}

method displayHelp{
    print("Available options are:")
    print("-get [url] to fetch a package located at a given url")
}

method printMessage(message){
    if (verbose)then{
        print(message)
    }
}

