import std.stdio, tcm.opthandler, std.algorithm, std.array, std.string, std.conv, tcm.colours, std.json, std.file, std.path, tcm.strplus, tcm.arrayplus;
import std.process : environment, executeShell;
import std.datetime.date, std.datetime.systime;


bool useFigletBanner = true;

void figlet(string banner){
  if(useFigletBanner){
    auto c = executeShell("figlet -c -k '"~banner~"'");
    if (c.status != 0){ useFigletBanner = false; writeln("Figlet missing, using standard stdio output."); }
    else writeln(c.output);
  }else banner.writeln;
}
JSONValue readDotJson(string pth){
  auto f = File(pth, "r");
  auto range = f.byLine();
  string txt;
    
  foreach (line; range)
    if (!line.empty) txt ~= line~"\n";
  return parseJSON(txt);
}
void writeDotJson(JSONValue data, string pth){
  auto f = File(pth, "w");

  string txt = data.toString;
  f.writeln(txt);

}

bool hasTag(JSONValue n, string tag){
  if("tags" in n){
    if(n["tags"].array.length > 0){
	foreach(t; n["tags"].array){
	  if(t.str == tag) return true;
	}
    }
  }
  return false;
}

string getFlag(JSONValue n, string tag){
  if("flag" in n){
    return n[tag].str;
  }
  return "";
}

void printNote(JSONValue n){
  auto dt = DateTime.fromSimpleString(n["dt"].str);
  string project = n["group"].str;
  string txt = n["text"].str;
  int i = n["id"].get!int;
  auto st = Clock.currTime();
  auto now = cast(DateTime)st;
  auto diff = now-dt;
  string p = "";
  if(project != "") p = ":"~project.red;
  string h = "#".cyan;
  writeln("| ["~h~i.to!string.cyan~p~"] Created "~diff.toString.yellow~" ago.");
  foreach(line; txt.split("\n")){
    writeln("| "~line.blue);
  }

  if("tags" in n){
    if(n["tags"].array.length > 0){
	string tln;
	foreach(t; n["tags"].array){
	  tln ~= t.str.cyan~",";
	}
	writeln("| Tags: "~tln.stripRight(","));
    }

  }

  if("flags" in n){
    //writeln(n["flags"].toJSON);
    foreach(k,v;n["flags"].object){
	if(v.str != "")
	writeln("| "~k.green~" = "~v.str.green);
    }
  }
}
void main(string[] argv){
  auto o = new Opt(argv);
  auto datapath = environment.get("ODIN_FILE");
  auto stop_datafile_warning = environment.get("ODIN_STOP_WARNING");
  if(datapath is null){ datapath = expandTilde("~/odin.json"); }
  if(!datapath.exists){ auto f = File(datapath, "w+"); f.writeln("{}"); writeln("Created data file..."); }
  
  switch(o.command(0, "help")){
  case "ls", "list": //add --hidden flag check to sho even hidden notes
    if(o.flag("h")){
	"Format: list".writeln;
	return;
    }
    int i = 0;
    auto d = readDotJson(datapath);
    writeln("-------------------");
    foreach (n; d["notes"].array){
	if(!n.hasTag("hidden")){
	  n["id"] = JSONValue(i);
	  n.printNote;
	  writeln("-------------------");
	}
	i++;
    }
    
    break;
  case "search", "s": //add --hidden flag check to sho even hidden notes
    if(o.flag("h")){
	"Format: search <text part> [--group:<group name>] [--tags:tag1,tag2] [--flag:key,val]".writeln;
	return;
    }
    int i = 0;
    auto d = readDotJson(datapath);
    writeln("-------------------");
    string group = o.value("group");
    string text = o.commands[1..$].join(" ");
    foreach (n; d["notes"].array){
	auto dt = DateTime.fromSimpleString(n["dt"].str);
	string project = n["group"].str;
	string txt = n["text"].str;
	auto st = Clock.currTime();
	auto now = cast(DateTime)st;
	auto diff = now-dt;
	bool showit = false;
	bool hidden = n.hasTag("hidden");
	if(!hidden && group != "" && project == group) showit = true;
	if(!hidden && text != "" && txt.contains(text)) {
	  string nln = text.red;
	  auto c = new Colours();
	  n["text"].str = n["text"].str.replace(text, text.red~""~c.blue);
	  showit = true;
	}
	if(!hidden && "tags" in n){
	  foreach(t;o.value("tags").split(",")){
	    if(n["tags"].array.length > 0){
		foreach(itn;n["tags"].array){
		  if(itn.str == t) showit = true;
		}
	    }

	  }
	}
	if(!hidden && showit){
	  n["id"] = JSONValue(i);
	  n.printNote;
	  writeln("-------------------");
	}
	i++;
    }
    break;
  case "delete", "del", "d", "remove", "rem", "r":
    if(o.flag("h")){
	"Format: delete <id>".writeln;
	return;
    }
    auto d = readDotJson(datapath);
    int needle = o.command(1).to!int;
    int i = 0;
    foreach (n; d["notes"].array){
	if(i == needle){
	  auto dt = DateTime.fromSimpleString(n["dt"].str);
	  string project = n["group"].str;
	  string txt = n["text"].str;
	  auto st = Clock.currTime();
	  auto now = cast(DateTime)st;
	  auto diff = now-dt;
	  
	  n["id"] = JSONValue(i);
	  n.printNote;
	  write("Delete this? (Enter `y` to confirm) > ");
	  if(readln().strip == "y"){
	    d["notes"].array = d["notes"].array.remove(i);
	    d.writeDotJson(datapath);
	    break;
	  }else{writeln("OK, not deleting.");}
	}

	i++;
    }
    break;
  case "done":
    if(o.flag("h")){
	"Format: done <id>".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath);
    if(i >= d["notes"].array.length){writeln("Invalid ID");return;}

    if("tags" in d["notes"].array[i]){
	if(d["notes"].array[i]["tags"].array.length > 0){
	  int ind;
	  foreach(itn;d["notes"].array[i]["tags"].array){
	    if(itn.str == "done"){
		d["notes"].array[i]["tags"].array = d["notes"].array[i]["tags"].array.remove(ind);
		d.writeDotJson(datapath);
		writeln("Note tagged as un-done.");
		return;
	    }

	    ind++;
	  }
	}

    }
    JSONValue tags;
    if("tags" in d["notes"].array[i]) {
	tags = d["notes"].array[i]["tags"];
	tags.array ~= JSONValue("done");
	d["notes"].array[i]["tags"] = tags;
    }else d["notes"].array[i]["tags"] = JSONValue(["done"]);
    
    d.writeDotJson(datapath);
    writeln("Note tagged as done");
    break;
  case "hide":
    if(o.flag("h")){
	"Format: hide <id>".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath);
    if(i >= d["notes"].array.length){writeln("Invalid ID");return;}

    if("tags" in d["notes"].array[i]){
	if(d["notes"].array[i]["tags"].array.length > 0){
	  int ind;
	  foreach(itn;d["notes"].array[i]["tags"].array){
	    if(itn.str == "hidden"){
		d["notes"].array[i]["tags"].array = d["notes"].array[i]["tags"].array.remove(ind);
		d.writeDotJson(datapath);
		writeln("Note tagged as un-hidden.");
		return;
	    }

	    ind++;
	  }
	}

    }
    JSONValue tags;
    if("tags" in d["notes"].array[i]) {
	tags = d["notes"].array[i]["tags"];
	tags.array ~= JSONValue("hidden");
	d["notes"].array[i]["tags"] = tags;
    }else d["notes"].array[i]["tags"] = JSONValue(["hidden"]);
    
    d.writeDotJson(datapath);
    writeln("Note tagged as hidden");
    break;
  case "check": //shows note by ID
    if(o.flag("h")){
	"Format: check <id>".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath)["notes"].array;
    if(i >= d.length){writeln("Invalid ID");return;}
    auto note = d[i];
    note["id"] = JSONValue(i);
    note.printNote;
    
    break;
  case "get": //gets config var
    if(o.flag("h")){
	"Format: get <var>".writeln;
	return;
    }
    auto d = readDotJson(datapath);
    if("settings" in d){
	auto s = d["settings"];
	if(o.command(1) in s){writeln(o.command(1).blue~" = "~s[o.command(1)].str.blue);}
    }
    break;
  case "set": //sets config var
    if(o.flag("h")){
	"Format: set <var> <value>".writeln;
	return;
    }
    auto d = readDotJson(datapath);
    JSONValue settings;
    if("settings" in d) settings = d["settings"];
    settings[o.command(1)] = o.command(2);
    d["settings"] = settings;
    d.writeDotJson(datapath);
    break;
  case "tag", "t":
    if(o.flag("h")){
	"Format: tag <id> <tag>".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath);
    if(i >= d["notes"].array.length){writeln("Invalid ID");return;}

    JSONValue tags;
    if("tags" in d["notes"].array[i]) {
	tags = d["notes"].array[i]["tags"];
	tags.array ~= JSONValue(o.command(2));
	d["notes"].array[i]["tags"] = tags;
    }else d["notes"].array[i]["tags"] = JSONValue([o.command(2)]);
    
    d.writeDotJson(datapath);
    break;
  case "untag", "ut":
    if(o.flag("h")){
	"Format: untag <id> <tag>".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath);
    if(i >= d["notes"].array.length){writeln("Invalid ID");return;}
    if("tags" in d["notes"].array[i]) {
	int nid = d["notes"].array[i]["tags"].array.countUntil(JSONValue(o.command(2))).to!int;
	if(nid < 0){ writeln("Tag not found.");return;}
	writeln("Removed tag "~d["notes"].array[i]["tags"].array[nid].str);
	d["notes"].array[i]["tags"].array = d["notes"].array[i]["tags"].array.remove(nid);
	d.writeDotJson(datapath);
	
    }

    
    break;
  case "flag", "fl":
    if(o.flag("h")){
	"Format: flag <id> <flag> [value]".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath);
    if(i >= d["notes"].array.length){writeln("Invalid ID");return;}

    JSONValue flags;
    if("flags" in d["notes"].array[i]) flags = d["notes"].array[i]["flags"];
    flags[o.command(2)] = o.command(3);
    d["notes"].array[i]["flags"] = flags;
    d.writeDotJson(datapath);
    break;
  case "append", "ap":
    if(o.flag("h")){
	"Format: append <id> <text>".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath);
    if(i >= d["notes"].array.length){writeln("Invalid ID");return;}
    string n = d["notes"].array[i]["text"].str~"\n"~o.commands[2..$].join(" ");
    d["notes"].array[i]["text"] = n;
    d.writeDotJson(datapath);
    d["notes"].array[i]["id"] = i;
    d["notes"].array[i].printNote;
    break;
  case "edit", "e":
    if(o.flag("h")){
	"Format: edit <id> <text>".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath);
    if(i >= d["notes"].array.length){writeln("Invalid ID");return;}
    string n = o.commands[2..$].join(" ");
    d["notes"].array[i]["text"] = n;
    d.writeDotJson(datapath);
    d["notes"].array[i]["id"] = i;
    d["notes"].array[i].printNote;
    break;
  case "replace", "rep":
    if(o.flag("h")){
	"Format: replace <id> <before> <after>".writeln;
	return;
    }
    int i = o.command(1).to!int;
    auto d = readDotJson(datapath);
    if(i >= d["notes"].array.length){writeln("Invalid ID");return;}

    writeln(" [Old] "~d["notes"].array[i]["text"].str.replace(o.command(2), o.command(2).red));
    string n = d["notes"].array[i]["text"].str.replace(o.command(2), o.command(3));
    d["notes"].array[i]["text"] = n;
    writeln(" [New] "~d["notes"].array[i]["text"].str.replace(o.command(3), o.command(3).green));
    d.writeDotJson(datapath);
    break;
    
  case "add", "a", "new", "n": //TODO add shell loop input if no text given
    if(o.flag("h")){
	"Format: add <text> [--group:<group name>] [--tags:tag1,tag2]".writeln;
	return;
    }
    JSONValue n;
    n["group"] = o.value("group");
    n["text"] = o.commands[1..$].join(" ");
    auto st = Clock.currTime();
    auto dt = cast(DateTime)st;
    n["dt"] = dt.toSimpleString();
    writeln("Note added.");
    auto d = readDotJson(datapath);
    if("notes" !in d){d["notes"] = JSONValue([n]);}
    else {
	d["notes"].array ~= n;
    }
    d.writeDotJson(datapath);
    break;
  case "help": //TODO add a kinda tags system, maybe instead of group
    //| some kinda custom variables for the output, maybe remaining opt values get added to a custom key object in the json
    "odin".figlet;
    
    "Commands:
add, a, new, n
delete, del, d, remove, rem, r
search, s
edit, e
replace, rep
append, ap
list, ls
check
flag
tag
untag
hide
done
get
set

Add -h to the end of the command to get help on that command.
Example: ./odin add -h
".writeln;

    writeln("Environment Variables:\nODIN_FILE="~environment.get("ODIN_STOP_WARNING", "null")~"\nODIN_STOP_WARNING="~environment.get("ODIN_STOP_WARNING", "null"));
    break;
    
  default:
    break;
  }
}
