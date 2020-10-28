rm(list=ls())
################################settings################################
#specifying how many top results should be included
top <- 10
#score file column to be extracted
column <- 2
#all amino acids of the experiment in alphabetic order
exp_aa <- c("A","C","D","E","F","H","I","K","L","M","N","Q","R","S","T","V","W","Y")
#wild type amino acid and colour
WT <- "F"
WT_colour <- "red3"
#plotting
y_lim <- c(-615,-580)
steps <- 5
########################################################################

#all amino acids order according to polarity and respective colours (apolar chartreuse3, polar orange1, cationic royalblue3, anionic tomato1)
all_aa <- c("A","F","I","L","M","V","W","C","N","Q","S","T","Y","H","K","R","D","E")
all_colours <- c("chartreuse3", "chartreuse3", "chartreuse3", "chartreuse3", "chartreuse3", "chartreuse3", "chartreuse3", "orange1", "orange1", "orange1", "orange1", "orange1", "orange1", "royalblue3", "royalblue3", "royalblue3", "tomato1", "tomato1")

#ordering aa according to all_aa vector
aa <- vector()
n <- 1
for (m in 1:length(all_aa)){
	if (is.element(all_aa[m], exp_aa)){
		aa[n] <- all_aa[m]
		n <- n+1
	}
}

#determining index vector for reordering from alphabethic to polarity order
index <- vector()
for (o in 1:length(exp_aa)){
	index[o] <- which(aa == exp_aa[o])
}

#select colours for the in aa specified aa
colours <- all_colours[match(aa, all_aa)]

#global plotting settings
par(mfrow=c(1,1),mgp=c(3,0.2,0), plt=c(0.13,0.94,0.06,0.83))

#list of all directories
dirs <- list.dirs('.', recursive=FALSE)

#determine number of directories
length_dirs <- length(dirs)

#determine number of subdirectories
length_subdirs <- vector()
i <- 0
for ( cur_dir in dirs ){
	i <- i+1
	length_subdirs[i] <- length(list.dirs(path = paste0(cur_dir), recursive=FALSE))
}
length_subdirs <- unique(length_subdirs)

if ( length(length_subdirs) == 1){
	
	#setting WT colour
	index_WT_reordered <- which(aa == WT)
	colours[index_WT_reordered] <- WT_colour
	
	#define array for results
	av_tot_sc <- array(0, dim = c(length_dirs, length_subdirs))
	sd_av_tot_sc <- array(0, dim = c(length_dirs, length_subdirs))

	i <- 0
	for ( cur_dir in dirs ){
		i <- i+1
		
		#list of all subdirectories
		subdirs <- list.dirs(path = paste0(cur_dir), recursive=FALSE)
		
		j <- 0
		for ( cur_subdir in subdirs ){
			j <- j+1
			
			#read data
			file_name <- list.files(path = paste0(cur_subdir), pattern="^all_scores(.*)txt$")
			subdir_data <- read.table(paste0(cur_subdir, "/", file_name), nrows=top) 
			
			#write total score to array
			av_tot_sc[i,j] <- mean(subdir_data[,column])
			sd_av_tot_sc[i,j] <- sd(subdir_data[,column])
		}
		
		#reordering according to specified indices
		av_tot_sc[i,] <- av_tot_sc[i,][order(index)]
		sd_av_tot_sc[i,] <- sd_av_tot_sc[i,][order(index)]
		
		#barplotting
		bar_centers <- barplot(height=av_tot_sc[i,],
							   ylim=y_lim,
							   lwd=1.3,
							   axes=FALSE,
							   xpd=FALSE,
							   col=colours
							   )
		#error bars
		arrows(bar_centers, av_tot_sc[i,]-sd_av_tot_sc[i,],
			   bar_centers, av_tot_sc[i,]+sd_av_tot_sc[i,],
			   code=3,
			   angle=90,
			   length=0.05,
			   lwd=1.5
			   )
		#y-axes on both sides
		axis(2, at=c(seq(y_lim[1],y_lim[2],steps)), tcl=0.5, las=1, cex.axis=1.2)
		axis(2, at=c(seq(y_lim[1]+steps/2,y_lim[2]-steps/2,steps)), tcl=0.3, label=FALSE)
		
		axis(4, at=c(seq(y_lim[1],y_lim[2],steps)), tcl=0.5, label=FALSE)
		axis(4, at=c(seq(y_lim[1]+steps/2,y_lim[2]-steps/2,steps)), tcl=0.3, label=FALSE)
		
		#x-axis at the top
		axis(3, at=bar_centers, tcl=0.2, las=1, cex.axis=1.04, label=aa)
		
		#box around the plot
		box(which="plot")
		
		#y-axis lable
		mtext(side=2, line=2.6, cex=1.2, substitute(paste(italic(average*" "*score*" "*top)*" ", num," / "*REU), list(num=top)), las=3)
		#x-axis lable
		mtext(side=3, line=1.6, cex=1.2, expression(italic(amino*" "*acid)))
		#title
		title(paste0(gsub("[./]","", cur_dir), " position ", gsub("[./A-Z]","", cur_subdir)), line=3.7, cex.main=1.4)
		
		#legend("bottom", legend=c("apolar", "polar", "cationic", "anionic", "WT"), fill=c("chartreuse3", "orange1", "royalblue3", "tomato1", "red3"), cex=1.1, ncol=5)
		
		dev.copy2pdf(file=paste0("Design_", gsub("[./]","", cur_dir), "_", gsub("[./A-Z]","", cur_subdir), ".pdf"))
	}
} else{ print("Warning. Different number of subdirectories!") }
