# key summary notes for awk newbies:
# awk variables are global, except for arguments of functions
# awk arrays [.] are hash arrays
# awk string concatenation is in the form "foo" bar"

# tested with GNU Awk 3.1.0
# run gawk -f anamat.awk -v mat=map_redmart.txt


BEGIN{

	# http://geeks.redmart.com/2015/01/07/skiing-in-singapore-a-coding-diversion/
	
	if(mat=="") {
		print "usage:"
		print "gawk -f anamat.awk -v mat=map_redmart.txt"
		exit
	}
	
	outfmat=mat # cmd=line variable		# "map_redmart.txt" or "map_redmart_example.txt"
	celldelim=" "
	hashdelim=":"
	chaindelim="->"
	
	
	ta= systime()
	
	hg_read()	# load the file
	hg_run()	# visit the map
	hg_rank()	# final report
	
	print "\nEND. elapsed: " (systime()-ta) "s."
}


################ data structures:
# hg[cell]
# queue_localpeak[cell]
# completed_path[path]
# best_set
# longest_set



function hg_run() {

	locpk=enqueue_local_peaks()
	print "\nlocal peaks:" locpk " elapsed: " (systime()-ta) "s ..."
	
	g_longest=0

	for(cpk in queue_localpeak) {
		split(cpk,a,hashdelim); r=a[1]; c=a[2]; delete a
		visit(r,c,1,cpk,"") # my r, my c, cum len, cum path, previous call hash
	}
	
}


function enqueue_local_peaks() {
	# for each cell, if no neighbour is higher, I am a local peak.
	local_peaks=0
	for(r=1;r<=rmax;r++) for(c=1;c<=cmax;c++) {	
		notalocalpeak = ishigher(r,c,-1,0) || ishigher(r,c,+1,0) || ishigher(r,c,0,+1) || ishigher(r,c,0,-1)	# N || S || E || W
		if(!notalocalpeak) {
			queue_localpeak[mathash(r,c)]=1
			local_peaks++
		}
	}
	return local_peaks
}






function visit(r,c,cumlen,cumpath,rcpv) {
	if(r > rmax || r < 1) return 0	# out of boundaries
	if(c > cmax || c < 1) return 0	# out of boundaries
	if(rcpv!="" && hg[mathash(r,c)] >= hg[rcpv]) return 0 # not strictly lower

	if( visit(r-1,c, cumlen+1, cumpath chaindelim mathash(r-1,c), mathash(r,c)) + \
		visit(r,c+1, cumlen+1, cumpath chaindelim mathash(r,c+1), mathash(r,c)) + \
		visit(r+1,c, cumlen+1, cumpath chaindelim mathash(r+1,c), mathash(r,c)) + \
		visit(r,c-1, cumlen+1, cumpath chaindelim mathash(r,c-1), mathash(r,c)) ==0) {
		# no further expansion is possible:
		if(cumlen == g_longest) {
			completed_path[cumpath]=1 
		}
		if(cumlen > g_longest) {
			delete completed_path
			completed_path[cumpath]=1
			g_longest = cumlen
		}
	}
	return 1
}


function ishigher(r,c,rinc,cinc) {
	# on testhigher true: true if neighbour exists and neighbour's height is strictly higher 
	rnb=r+rinc
	cnb=c+cinc
	if(rnb > rmax || rnb < 1) return 0
	if(cnb > cmax || cnb < 1) return 0
	myneighbour=mathash(rnb,cnb)
	myself=mathash(r,c)
	if(hg[myneighbour] > hg[myself]) return 1
	return 0
}


function hg_rank() {
	best=0
	delete best_set
	for(p in completed_path) {
		curr=path_measure_max_len(p)
		if(curr == best) best_set[p]=1 	# just found a best mate
		if(curr > best) {				# just found a new best
			best = curr
			delete best_set
			best_set[p]=1
		}
	}
	print "\nBEST SET (LEN) ==================="
	for(p in best_set) path_display(p)

	for(i in best_set) longest_set[i]=1	# array copy
	best=0
	delete best_set
	for(p in longest_set) {
		curr=path_measure_max_drop(p)
		if(curr == best) best_set[p]=1	# just found a best mate
		if(curr > best) {				# just found a new best
			best = curr
			delete best_set
			best_set[p]=1
		}
	}
	print "\nBEST OF THE BEST SET (DROP) ==================="
	for(p in best_set) path_display(p)

}

		
function path_measure_max_drop(path) {
	# assumptions: the first is the highest and the last is the lowest
	n=split(path,cell,chaindelim)
	return hg[cell[1]] - hg[cell[n]]
}


function path_measure_max_len(path) {
	return split(path,dummy,chaindelim)
}


function path_display(p) {
		print p " (LEN:" path_measure_max_len(p) ",DROP:" path_measure_max_drop(p) ")"
}






function hg_read() {
	# read file into matrix ...
	
	# getline returns one if it finds a record, and zero if the end of the file is encountered. 
	# If there is some error in getting a record, such as a file that cannot be opened, then getline returns -1. 
	# In this case, gawk sets the variable ERRNO to a string describing the error that occurred. 
	
	# special_first_input_line
	getline oneline < outfmat
	split(oneline, cell, celldelim)
	rmax=cell[1]
	cmax=cell[2]
	delete cell
	
	for(r=1;r<=rmax;r++) {
		getline oneline < outfmat
		split(oneline, cell, celldelim)
		for(c=1;c<=cmax;c++) {
			hg[mathash(r,c)] = cell[c]
		}
		delete cell
	}
}

function mathash(r,c) {
	return r hashdelim c
}

	
