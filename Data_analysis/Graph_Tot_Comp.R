rm(list=ls())
################################settings################################
#specifying how many top results should be included
top <- 10
#all amino acids of the experiment in alphabetic order
exp_aa <- c("A","F","H","I","S","T","V","W","Y")
#wild type amino acid and colour
WT <- "F"
WT_colour <- "red3"
#directories that should be compared (the last one is the one by which is devided)
dirs <- c("./NKR", "./NKS")
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

#global plotting parameters
par(mfrow=c(1,1),mgp=c(3,0.2,0), plt=c(0.16,0.94,0.06,0.83))

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
			av_tot_sc[i,j] <- mean(subdir_data[,2])
			sd_av_tot_sc[i,j] <- sd(subdir_data[,2])
		}
		
		#reordering according to specified indices
		av_tot_sc[i,] <- av_tot_sc[i,][order(index)]
		sd_av_tot_sc[i,] <- sd_av_tot_sc[i,][order(index)]
		
		#barplotting
		bar_centers <- barplot(height=av_tot_sc[i,],
							   ylim=c(-825,-800),
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
		axis(2, at=c(-800,-805,-810,-815,-820,-825), tcl=0.5, las=1, cex.axis=1.2)
		axis(2, at=c(-802.5,-807.5,-812.5,-817.5,-822.5), tcl=0.3, label=FALSE)
		
		axis(4, at=c(-800,-805,-810,-815,-820,-825), tcl=0.5, label=FALSE)
		axis(4, at=c(-802.5,-807.5,-812.5,-817.5,-822.5), tcl=0.3, label=FALSE)
		
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
		
		dev.copy2pdf(file=paste0("Design_", gsub("[./]","", cur_dir), "_", gsub("[./A-Z]","", cur_subdir), ".pdf"))	
	}
	
	for (l in 1:(length_dirs-1)){
		
		#calculate ratio
		ratio <- av_tot_sc[l,]/av_tot_sc[length_dirs,]
		sd_ratio <- sqrt((sd_av_tot_sc[l,]/av_tot_sc[l,])^2+(sd_av_tot_sc[length_dirs,]/av_tot_sc[length_dirs,])^2)*ratio
		
		#determine the new indices
		change_index <- c(1:length_subdirs+1)
		change_index[index_WT_reordered] <- 1
		change_index[(index_WT_reordered+1):length_subdirs] <- change_index[(index_WT_reordered+1):length_subdirs]-1
		
		#normalise reatio to WT
		norm_ratio <- ratio/ratio[index_WT_reordered]-1
		sd_norm_ratio <- sqrt((sd_ratio/ratio)^2+(sd_ratio[index_WT_reordered]/ratio[index_WT_reordered])^2)*(norm_ratio+1)
		
		#apply nw indices
		norm_ratio <- norm_ratio[order(change_index)]
		sd_norm_ratio <- sd_norm_ratio[order(change_index)]
		
		#barplotting
		bar_centers <- barplot(height=norm_ratio[2:length_subdirs],
								   ylim=c(-0.006,0.004),
								   lwd=1.3,
								   axes=FALSE,
								   xpd=FALSE,
								   col=colours[order(change_index)][2:length_subdirs]
								   )
		
		#error bars
		#arrows(bar_centers, norm_ratio[2:length_subdirs]-sd_norm_ratio[2:length_subdirs],
			  # bar_centers, norm_ratio[2:length_subdirs]+sd_norm_ratio[2:length_subdirs],
			  # code=3,
			  # angle=90,
			  # length=0.05,
			  # lwd=1.5
			  # )
		
		#y-axes on both sides
		axis(2, at=c(-0.006,-0.004,-0.002,0,0.002,0.004), tcl=0.5, las=1, cex.axis=1.2, label=c(0.994,0.996,0.998,1.000,1.002,1.004))
		axis(2, at=c(-0.005,-0.003,-0.001,0.001,0.003), tcl=0.3, label=FALSE)
		
		axis(4, at=c(-0.006,-0.004,-0.002,0,0.002,0.004), tcl=0.5, label=FALSE)
		axis(4, at=c(-0.005,-0.003,-0.001,0.001,0.003), tcl=0.3, label=FALSE)
		
		#x-axis
		axis(1, at=bar_centers, tcl=0.3, label=FALSE, pos=0)
		axis(3, at=bar_centers, tcl=0.3, label=FALSE, pos=0)
		abline(0,0)
		
		#bar labels
		for (k in 2:length_subdirs){
			if ( norm_ratio[k] >= 0 ){
				text(x=bar_centers[k-1], y=norm_ratio[k], label=aa[order(change_index)][k], pos=3, cex=1.04)
			}
			if ( norm_ratio[k] < 0 ){
				text(x=bar_centers[k-1], y=norm_ratio[k], label=aa[order(change_index)][k], pos=1, cex=1.04)
			}
		}
		
		#box around the plot
		box(which="plot")
		
		#y-axis lable
		mtext(side=2, line=3.2, cex=1.2, substitute(paste(italic(normalisied*" "*ratio*" "*f [aa] ^norm)), list(num=top)), las=3)
		#title
		title(paste0(gsub("[./]","", dirs[l]), "/", gsub("[./]","", dirs[length_dirs]), " position ", gsub("[./A-Z]","", cur_subdir)), line=2.4, cex.main=1.4)
		
		dev.copy2pdf(file=paste0("Comp_", gsub("[./]","", dirs[l]), "_", gsub("[./]","", dirs[length_dirs]), "_", gsub("[./A-Z]","", cur_subdir), ".pdf"))
	}
} else{ print("Warning. Different number of subdirectories!") }
