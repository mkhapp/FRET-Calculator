Table.create("Final Results");

//Calculate MEMBRANE Da, Fa, Aa
waitForUser("Please open your Acceptor Image.");
ROIsMembraneCyto(getTitle());
roiManager("Select", 0);
roiManager("multi measure");
Da = Table.get("Mean1", 0, "Results");
Fa = Table.get("Mean1", 1, "Results");
Aa = Table.get("Mean1", 2, "Results");
run("Clear Results");
roiManager("reset");
backgrounds = GetBackground(getTitle());
if (Da > backgrounds[0]) {
	Da = Da - backgrounds[0];
} else {
	Da = 0;
}
if (Fa > backgrounds[1]) {
	Fa = Fa - backgrounds[1];
} else {
	Fa = 0;
}
if (Aa > backgrounds[2]) {
	Aa = Aa - backgrounds[2];
} else {
	Aa = 0;
}
run("Clear Results");
close("*");
//Array.print(newArray(Da, Fa, Aa));

//Calculate MEMBRANE Dd, Fd, Ad
waitForUser("Please open your Donor Image.");
ROIsMembraneCyto(getTitle());
roiManager("Select", 0);
roiManager("multi measure");
Dd = Table.get("Mean1", 0, "Results");
Fd = Table.get("Mean1", 1, "Results");
Ad = Table.get("Mean1", 2, "Results");
run("Clear Results");
roiManager("reset");
backgrounds = GetBackground(getTitle());
if (Dd > backgrounds[0]) {
	Dd = Dd - backgrounds[0];
} else {
	Dd = 0;
}
if (Fd > backgrounds[1]) {
	Fd = Fd - backgrounds[1];
} else {
	Fd = 0;
}
if (Ad > backgrounds[2]) {
	Ad = Ad - backgrounds[2];
} else {
	Ad = 0;
}
run("Clear Results");
close("*");
//Array.print(newArray(Dd, Fd, Ad));

//Calculate MEMBRANE and CYTO Ff, Df, Af for each slice
waitForUser("Please open your FRET Image.");

do {
	setTool("multipoint");
	run("Select None");
	waitForUser("Place a single point in a background area.");
	getSelectionBounds(x, y, width, height);
	} while (width > 1);
	
num = nSlices;
	
for (i = 0; i < num; i++) {
	//get image name
	title = getTitle();
	
	//get the proper slice
	run("Slice Keeper", "first="+(3*i+1)+" last="+(3*i+3)+" increment=1");
	
	//get background values
	backgrounds = GetBackgroundPreviousInput(getTitle(), x, y);
	run("Clear Results");
	run("Select None");
	
	//calculate membrane values (no background yet)
	ROIsMembraneCyto(getTitle());
	roiManager("Select", 0);
	roiManager("multi measure");
	Dfm = Table.get("Mean1", 0, "Results");
	Ffm = Table.get("Mean1", 1, "Results");
	Afm = Table.get("Mean1", 2, "Results");
	run("Clear Results");
	
	//adjust membrane values for background
	if (Dfm > backgrounds[0]) {
		Dfm = Dfm - backgrounds[0];
	} else {
		Dfm = 0;
	}
	if (Ffm > backgrounds[1]) {
		Ffm = Ffm - backgrounds[1];
	} else {
		Ffm = 0;
	}
	if (Afm > backgrounds[2]) {
		Afm = Afm - backgrounds[2];
	} else {
		Afm = 0;
	}
	
	//calculate cyto values (no background yet)
	roiManager("Select", 1);
	roiManager("multi measure");
	Dfc = Table.get("Mean1", 0, "Results");
	Ffc = Table.get("Mean1", 1, "Results");
	Afc = Table.get("Mean1", 2, "Results");
	run("Clear Results");
	
	//adjust cyto values for background
	if (Dfc > backgrounds[0]) {
		Dfc = Dfc - backgrounds[0];
	} else {
		Dfc = 0;
	}
	if (Ffc > backgrounds[1]) {
		Ffc = Ffc - backgrounds[1];
	} else {
		Ffc = 0;
	}
	if (Afc > backgrounds[2]) {
		Afc = Afc - backgrounds[2];
	} else {
		Afc = 0;
	}
	
	NFRETm = (Ffm-(Dfm*Fd/Dd)-(Afm*Fa/Aa))/Math.sqrt(Dfm*Afm);
	NFRETc = (Ffc-(Dfc*Fd/Dd)-(Afc*Fa/Aa))/Math.sqrt(Dfc*Afc);
	
	Table.set("Image Name", i, title, "Final Results");
	Table.set("Frame", i, i+1, "Final Results");
	Table.set("Da", i, Da, "Final Results");
	Table.set("Fa", i, Fa, "Final Results");
	Table.set("Aa", i, Aa, "Final Results");
	Table.set("Dd", i, Dd, "Final Results");
	Table.set("Fd", i, Fd, "Final Results");
	Table.set("Ad", i, Ad, "Final Results");
	Table.set("Dfm", i, Dfm, "Final Results");
	Table.set("Ffm", i, Ffm, "Final Results");
	Table.set("Afm", i, Afm, "Final Results");
	Table.set("Dfc", i, Dfc, "Final Results");
	Table.set("Ffc", i, Ffc, "Final Results");
	Table.set("Afc", i, Afc, "Final Results");
	Table.set("NFRET (membrane)", i, NFRETm, "Final Results");
	Table.set("NFRET (cytoplasm)", i, NFRETc, "Final Results");
	Table.update("Final Results");
	
	
	
	//Array.print(newArray(Dfm,Ffm,Afm));
	//Array.print(newArray(Dfc,Ffc,Afc));
	roiManager("reset");
	close();
	
}

print("Finished!");




//function - generate membrane and cyto ROIs
function ROIsMembraneCyto(imagetitle) { 
// generates two ROIs - one for the cell membrane, and one for the cell cytoplasm
	run("Set Measurements...", "mean redirect=None decimal=0");
	selectImage(imagetitle);
	run("Cellpose ...", "env_path=C:\\Users\\travermk\\AppData\\Local\\miniconda3\\envs\\cellpose env_type=conda model=cyto3 model_path=path\\to\\own_cellpose_model diameter=150 ch1=0 ch2=-1 additional_flags=--use_gpu");
	run("Make Binary");
	run("Analyze Particles...", "size=1-Infinity add");
	run("Options...", "iterations=12 count=1");
	run("Erode");
	run("Analyze Particles...", "size=1-Infinity add");
	roiManager("Select", newArray(0,1));
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", newArray(0,1));
	roiManager("Delete");
	run("Options...", "iterations=18 count=1");
	run("Erode");
	run("Analyze Particles...", "size=1-Infinity add");
	close();
}


//function - calculate background values
function GetBackground(imagetitle) { 
// returns array with background value (a user-defined area) of each channel in order
	run("Set Measurements...", "mean redirect=None decimal=0");
	do {
	setTool("multipoint");
	run("Select None");
	waitForUser("Place a single point in a background area.");
	getSelectionBounds(x, y, width, height);
	} while (width > 1);

	makeOval(x-25, y-25, 50, 50);
	roiManager("add");
	roiManager("multi measure");
	roiManager("reset");
	backgrounds = Table.getColumn("Mean1", "Results");
	return backgrounds;
}

//function - calculate background values
function GetBackgroundPreviousInput(imagetitle, x, y) { 
// returns array with background value of a previously defined area of each channel in order
	run("Set Measurements...", "mean redirect=None decimal=0");
	
	makeOval(x-25, y-25, 50, 50);
	roiManager("add");
	roiManager("multi measure");
	roiManager("reset");
	backgrounds = Table.getColumn("Mean1", "Results");
	return backgrounds;
}

