
#import "@preview/timeliney:0.1.0"
#import "@preview/subpar:0.2.0"
#import "@preview/acrostiche:0.4.1": *

// Set up page, paragraphs, text size
#set page(margin: (top: 1.25cm, bottom: 1cm, left: 1.5cm, right: 2.5cm), numbering: "1", number-align: right)
#set par(
  spacing: 0.65em,
  first-line-indent: 1em,
  justify: true,
)
#set text(
  size: 10pt,
)
// Heading numbering 1.0, 1.1, 1.1.1
#set heading(
  numbering: "1.",
)

// Defines acronyms when first used
// pl - plural uses 
// Acrostiche
#init-acronyms((
  "la": (
short: "LATATW",
long: "Long And Tedious Acronym To Write",
short-pl: "LATAsTW",
long-pl: "Long And Tedious Acronyms To Write"),
))


= Hello
== 

This is a test of the timeliney preview.

#pagebreak()
#set page( 
flipped: true,
  paper: "a4",
  margin: (x: 0.15cm, y: 0.15cm)
)

#set text(
  size: 5pt,
)
// Define some styles
#let tl_deliverables   = (stroke:2pt + color.rgb("#f75757"))
#let tl_research       = (stroke:2pt + color.rgb("#f1aa30"))
#let tl_implementation = (stroke:2pt + color.rgb("#7bfc61"))
#let tl_verification   = (stroke:2pt + color.rgb("#6bfaff"))
#let tl_syseng         = (stroke:2pt + color.rgb("#dc62fa"))
// Week offsets
#let sem1 = 0
#let sem2 = 16
#let exam = 11
#let os_break = 13



#timeliney.timeline(
  show-grid: true,
  spacing: 5pt,
  milestone-layout: "in-place",
  {
    import timeliney: *
      
    headerline(
                group(([*Semester 1*], 13)),
                group(([*Break*],       3)), 
                group(([*Semester 2*], 12))
                )
    headerline(
      group(..range(11).map(n => strong("W" + str(n + 1)))),
      group(..range(2).map(n => strong("E" + str(n + 1)))),
      group(..range(3).map(n => strong("C" + str(n + 1)))),
      group(..range(12).map(n => strong("W" + str(n + 0)))),
    )
    
    taskgroup(title: [*D - Deliverables*], {
      task("D1 - Statement of Intent",   (1+sem1,   3+sem1),  style: tl_deliverables)
      task("D2 - Interim Report",        (10+sem1,  13+sem1), style: tl_deliverables)
      task("D3 - Poster",                (2+sem2,   7+sem2),  style: tl_deliverables)
      task("D4 - Final Report",          (7+sem2,   11+sem2), style: tl_deliverables)
        })
        
        taskgroup(title:[*R1 - Research - STRATHcube*], {
      task("R1.1 - Mission Requirements",  (4.5+sem1,11+sem1), style: tl_research)
      task("R1.2 - Data Handling",         (6+sem1, 11+sem1),  style: tl_research)
      task("R1.3 - Link Budget",           (2+sem1, 6+sem1),   style: tl_research)
      task("R1.4 - TOTEM SDR",             (1+sem1, 11+sem1),  style: tl_research)
        })

        taskgroup(title: [*R2 - Research - DVB-S2*], {
      task("R2.1 - ACM",                      (2.5+sem1,9.5+sem1),  style: tl_research)
      task("R2.2 - Standard",                 (2+sem1,  5+sem1),    style: tl_research)
      task("R2.3 - Existing Implementations", (1+sem1,  1+os_break),style: tl_research)
        })

        taskgroup(title: [*R3 - Research - Packet Handling*], {
      task("R3.1 - XTCE Standard",         (3+sem1, 3+os_break),    style: tl_research)
      task("R3.2 - Libraries",             (6+sem1, 11+sem1),       style: tl_research)
        })              
        
        taskgroup(title:[*S - Systems Engineering*], {
      task("S1 - Requirements",            (4+sem1, 12+sem1),   style: tl_syseng)
        })

        taskgroup(title:[*I1 - Implementation - Transmitter*], {
      task("I1.1 - Resource Usage Analysis", (5+sem1,   8+sem1),   style: tl_implementation)
      task("I1.2 - Transceiver Integration", (11.5+sem1,3+sem2),   style: tl_implementation)
      task("I1.3 - Resource Optimisation",   (9+sem2,   11+sem2),  style: tl_implementation)
      task("I1.4 - Libiio Driver",           (0+sem2,   4+sem2),   style: tl_implementation)
      task("I1.5 - GNU Radio Integration",   (3+sem2,   4+sem2),   style: tl_implementation)
        })

        taskgroup(title:[*I2 - Implementation - Packet Handling*], {
      task("I2.1 - System Interfacing",      (2+exam, 0.5+sem2), style: tl_implementation)
      task("I2.2 - XTCE",                    (2+exam, 6+sem2),   style: tl_implementation)
      task("I2.3 - Scheduling",              (5+sem2, 7+sem2),   style: tl_implementation)
      task("I2.4 - PL Interfaces",           (2+sem2, 3+sem2),   style: tl_implementation)  
        })

        taskgroup(title:[*V1 - Verification - Required*], {
      task("V1.1 - Timing Closure",               (1+sem2, 2+sem2),   style: tl_verification)
      task("V1.2 - Individual component testing", (0+sem2, 6.5+sem2), style: tl_verification)
      task("V1.3 - System Testing",               (7+sem2, 10+sem2),  style: tl_verification)
      task("V1.4 - Performance Requirements",     (7+sem2, 10+sem2),  style: tl_verification)
        })

        taskgroup(title:[*V2 - Verification - Optional*], {
      task("V2.1 - Hardware in the Loop",    (8+sem2, 10+sem2),  style: tl_verification)
      task("V2.2 - Memory Corruption",       (8+sem2, 10+sem2),  style: tl_verification)
        })
    
    // Deadlines
    milestone(
      at: 3+sem1,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Statement of Intent*\
        week 3 S1
      ])
    )
    milestone(
      at: 2+exam,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Interim Report*\
        Exam Week 2
      ])
    )
    milestone(
      at: 7+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Poster*\
        week 7 S2
      ])
    )
    milestone(
      at: 11+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *Final Report*\
        week 11 S2
      ])
    )

    // Development Decision Points
    milestone(
      at: 10+sem1,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *DP1 - Dev v Flight HW*\
        week 10 S1
      ])
    )
    milestone(
      at: 8+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        \
        \

        *DP2 - HW Testing v Software Completion*\
        week 8 S2
      ])
    )
    
    // Development Milestones
    milestone(
      at: 11+sem1,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *MS1 - System Architecture*\
        week 11 S1
        
      ])
    )
    milestone(
      at: 3+sem2,
      style: (stroke: (dash: "dashed")),
      align(center, [
        *MS2 - System Prototype*\
        week 3 S2
        
      ])
    )

  }
)
#set page( 
flipped: false,
  paper: "a4"
)
#pagebreak()
