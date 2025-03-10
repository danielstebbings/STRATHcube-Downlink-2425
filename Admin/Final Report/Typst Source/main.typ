#import "template.typ": *
#import "@preview/codelst:2.0.2": sourcecode
#import "@preview/acrostiche:0.5.1": *


#init-acronyms((
  //"WTP": ("Wonderful Typst Package","Wonderful Typst Packages"),
))

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Downlink System Design for the STRATHcube Satellite Mission",

  //takes in a list of dicts (name: full_name, reg: registration_number)
  authors: (
    (name: "Daniel Stebbings", reg: "202118874"),
  ),
  
  declaration: [
  I confirm and declare that this report and the project work is entirely the product of my own effort and I have not used or presented the work of others herein without acknowledgment
  ],

  abstract: [
   
  ],
  
  subtitle: [
  Supervis \
  Department of Electronic and Electrical Engineering \
  University of Strathclyde, Glasgow
  ],
  
  // date: [your custom date]
  //default is datetime.today().display("[day] [month repr:long] [year]")
  
  // whether to gen a list of figs
  figures: true,
  
  // special space fro the glossary
  glossary: [#print-index(title: "Definitions")],
  
  // whether to gen the ack at the bottom
  ack: false,

  // compact layeout for assignments, set to false for more "grandeur"
  compact: false
)
// table titles at the top if you like it that way
#show figure.where(
  kind: table
): set figure.caption(position: top)

// body

//Abstract
//1. Introduction
//2. Background
//3. ACM Analysis
//4. HDL Implementation
//Appendices


= Introduction
= Background
= ACM Analysis
#include("link_budget.typ")






= DVB-S2 
= Code listings

#figure(sourcecode[```C
example_c_code() =
example_c_code() = 
example_c_code() = 
example_c_code() = 
example_c_code() = 
```], caption: [code listing])

#show bibliography: set heading(numbering: "1")
//#bibliography("example.bib")

