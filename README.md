<h1>ChoiceScript</h1>
<p>A C-based parser for ChoiceScript coded with Flex, Bison and LaTeX.<p>
   <p>It supports most ChoiceScript commands except mathematical operations, conditionals and variable assignments.</p>
   <p>The sample folder consists of .txt files that have been parsed successfully by this parser.</p>
   <p>Simple LaTeX commands have been used to generate the .pdf file once parsing is finished.</p>
   <p>Please refer to the TODO in this repository for features that could be added in the future.</p>
<h2>Installation</h2>
<p>This project works perfectly on Linux, adjustments for Windows and Mac will be made in the future.</p> 
   <p> 1. Open your <b>Terminal</b> and type the following commands as needed.
       <p>
<ul><b>git:</b> sudo apt install git</ul>
        <ul><b>gcc & make:</b> sudo apt install build-essential</ul>
        <ul><b>Flex:</b> sudo apt-get install flex</ul>
        <ul><b>Bison:</b> sudo apt-get install bison</ul>
        <ul><b>LaTeX:</b> sudo apt-get install texlive </ul></p>
    </p>
<p>2. In your desired directory run:
    <ul>git clone “https://github.com/abigya/ChoiceScript.git”</ul>
    <ul>This will create a copy of this project on your computer.</ul></p>
 <h2>Build</h2>
<ul>1.	Open<b>Terminal</b> and cd to the ChoiceScript folder. </ul>
<ul>2.	Type make. This will build the project with the object files. 
    <br> 
      <img src ="https://github.com/abigya/ChoiceScript/blob/master/images/make.PNG">
    </ul>
<ul>3.	Type make test to test the project. Simply typing “make test” will write all output to startup.tex. This will fail if there are any errors.
    <br>
    <img src = "https://github.com/abigya/ChoiceScript/blob/master/images/maketest.PNG">
    </ul>
 
<ul>4.	Type make latex to create the book. You might need to rerun it again if you made changes to any labels in the LaTex code.
<br>
    <img src = "https://github.com/abigya/ChoiceScript/blob/master/images/makelatex.PNG">
    </ul>
 
<ul>5.	Go back to your ChoiceScript folder and open startup.pdf to read your story.
<br>
    <img src = "https://github.com/abigya/ChoiceScript/blob/master/images/pdffile.PNG">
    </ul>
 
<ul>6.	Type make clean to remove all object files. This will remove startup.pdf as well.
 <br>
    <img src = "https://github.com/abigya/ChoiceScript/blob/master/images/makeclean.PNG">
</ul>

 






