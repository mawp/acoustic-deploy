#' @name change
#' @title Reads in the input file, and replaces all matching pattern with value.
#' @param input Path to the file to read.
#' @param output Path to the file to output.
#' @param pattern The pattern to search for and replace.
#' @param value The value to replace matched patterns with.
#' @return N/A
change <- function(input, output, pattern, value, debug=TRUE) {
	conn <- file(input, "r")
	options(warn=-1)
	out =  readLines(conn, 1)
	while(length(line <- readLines(conn, 1)) > 0) {
		out = paste(out, line, sep="\n")
	}
	close(conn)
	conn <- file(output, "w+")
	out = gsub(pattern, value, out)
	cat(out,file=output)
	close(conn)
	if(debug) {
		cat(sprintf("Changed all references to \'%s\' to \'%s\' in \'%s\'\n", pattern, value, output))
	}
}

#install and load roxygen2
install.packages("roxygen2", repos='http://cran.cnr.Berkeley.edu')
library(roxygen2)

# name of the package to create (Fill in whatever you want)
packageName = "acoustic"

# Names of source files.  These must exist in 'src/' folder of the working directory.
files = c("Description.R",
		"Bathy.R", 
		"FishModel.R", 
		"Utility.R", 
		"ShapeFunctions.R", 
		"Main.R")

# Delete any old packages of the same name
unlink(packageName, TRUE)

# A bug in package.skeleton() requires us to import these...
library(methods)
library(utils)

code_files = {}
for (file in files) {
	code_files = c(code_files, paste("src/", file, sep=""))
}

# Sets up the default package directories and files
package.skeleton(packageName, 
		code_files=code_files)

# Changes all file paths in source() calls to their new values.
for (file in files) {
	name = paste(packageName, "/R/", file, sep="")
	change(name, name, "src/", "")
}

# Call Roxygen to make the .Rd files
print('--- Roxygenize ---')
roxygenize(packageName, copy=FALSE)

# Changes all file paths in source() calls to their new values.
for (file in files) {
	name = paste(packageName, "/R/", file, sep="")
	change(name, name, paste("source\\(\'", sep=""),paste("source\\(","\'R/", sep=""))
}

# write a list of files to file for the help.html file to read.
rdFiles = list.files(paste(packageName, "/man", sep=""))
rdFiles = gsub(".Rd", "", rdFiles)
rdFiles = gsub(" ", "", rdFiles)
toPrint = "<?xml version=\"1.0\"?><Names>\n"
for (file in rdFiles) {
	toPrint = paste(toPrint, "<Name>",file,"</Name>\n", sep="")
}
toPrint = paste(toPrint, "</Names>", sep="")
cat(toPrint, file="pages/help_pages/index.xml", sep="\n")

