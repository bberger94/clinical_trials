Here's a quick description of how to recreate the graphs in `~/Dropbox/Chandra-Stern-Pharma/F_Trials start data/reports/graphs.docx`.

1.  Install the following software:

    a.  [Stata](http://www.stata.com/)
    b.  [Pandoc](http://pandoc.org/)
    c.  [Make](https://www.gnu.org/software/make/)

2.  Open a [terminal](https://en.wikipedia.org/wiki/Comparison_of_terminal_emulators).

3.  Navigate to this directory:

        cd ~/Dropbox/Chandra-Stern-Pharma/F_Trials\ start\ data/

4.  Run the following command:

        make stata=/Applications/Stata/StataMP.app/Contents/MacOS/stata-mp reports/graphs.docx
        
    Note that the path to Stata on your machine may be different from mine.


# Old data

I've moved old data files to the HBS Grid. They are available at `/export/projects/astern_trials/archive/F_Trials start data`.


# References

I've structured this directory to follow the [Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/) guidelines.

You might enjoy [this post](https://bost.ocks.org/mike/make/) on how to use Make.
