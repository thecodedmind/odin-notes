module tcm.colours;
import std.string;

string black(string s){return "\u001b[30m"~s~"\u001b[0m";}
string red(string s){return "\u001b[31m"~s~"\u001b[0m";}
string green(string s){return "\u001b[32m"~s~"\u001b[0m";}
string yellow(string s){return "\u001b[33m"~s~"\u001b[0m";}
string blue(string s){return "\u001b[34m"~s~"\u001b[0m";}
string magenta(string s){return "\u001b[35m"~s~"\u001b[0m";}
string cyan(string s){return "\u001b[36m"~s~"\u001b[0m";}
string white(string s){return "\u001b[37m"~s~"\u001b[0m";}

string brightblack(string s){return "\u001b[30;1m"~s~"\u001b[0m";}
string brightred(string s){return "\u001b[31;1m"~s~"\u001b[0m";}
string brightgreen(string s){return "\u001b[32;1m"~s~"\u001b[0m";}
string brightyellow(string s){return "\u001b[33;1m"~s~"\u001b[0m";}
string brightblue(string s){return "\u001b[34;1m"~s~"\u001b[0m";}
string brightmagenta(string s){return "\u001b[35;1m"~s~"\u001b[0m";}
string brightcyan(string s){return "\u001b[36;1m"~s~"\u001b[0m";}
string brightwhite(string s){return "\u001b[37;1m"~s~"\u001b[0m";}

string fg(string s, string id){return "\u001b[38;5;"~id~"m"~s~"\u001b[0m";}
string bg(string s, string id){return "\u001b[48;5;"~id~"m"~s~"\u001b[0m";}

string bold(string s){return "\u001b[1m"~s~"\u001b[0m";}
string underline(string s){return "\u001b[4m"~s~"\u001b[0m";}
string resetfmt(string s){return "\u001b[0m"~s~"\u001b[0m";}

class Colours {
  string black = "\u001b[30m";
  string red = "\u001b[31m";
  string green = "\u001b[32m";
  string yellow = "\u001b[33m";
  string blue = "\u001b[34m";
  string magenta = "\u001b[35m";
  string cyan = "\u001b[36m";
  string white = "\u001b[37m";
  string bright_black = "\u001b[30;1m";
  string bright_red = "\u001b[31;1m";
  string bright_green = "\u001b[32;1m";
  string bright_yellow = "\u001b[33;1m";
  string bright_blue = "\u001b[34;1m";
  string bright_magenta = "\u001b[35;1m";
  string bright_cyan = "\u001b[36;1m";
  string bright_white = "\u001b[37;1m";
  
  string bg_black = "\u001b[40m";
  string bg_red = "\u001b[41m";
  string bg_green = "\u001b[42m";
  string bg_yellow = "\u001b[43m";
  string bg_blue = "\u001b[44m";
  string bg_magenta = "\u001b[45m";
  string bg_cyan = "\u001b[46m";
  string bg_white = "\u001b[47m";
  string bg_bright_black = "\u001b[40;1m";
  string bg_bright_red = "\u001b[41;1m";
  string bg_bright_green = "\u001b[42;1m";
  string bg_bright_yellow = "\u001b[43;1m";
  string bg_bright_blue = "\u001b[44;1m";
  string bg_bright_magenta = "\u001b[45;1m";
  string bg_bright_cyan = "\u001b[46;1m";
  string bg_bright_white = "\u001b[47;1m";

  
  string bold = "\u001b[1m";
  string underline = "\u001b[4m";
  string reversed = "\u001b[7m";

			   
  string reset = "\u001b[0m";

  string fg(string id){
    return "\u001b[38;5;"~id~"m";
  }
  string bg(string id){
    return "\u001b[48;5;"~id~"m";
  }
  string get(string id){
    return "\u001b["~id;
  }
}
