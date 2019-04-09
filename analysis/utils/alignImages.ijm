// Macro to Make Stacks and Aligned Stacks out of image sequences
macro "MakeStacks_J" {

	// prompt user for source directory
//	dir1 = getDirectory("Choose Source Directory ");
//
//	// read in file listing from source directory
//	list = getFileList(dir1);

//	print("Making a stack from files in directory "+dir1);



//			print("processing directory "+list[i]);
		
			// Open the image sequence of Ch1
			input_string = getArgument();
			// Delimiter is two newline characters because, honestly, when will
			// that appear in a valid input anyway?
			input_array = split(input_string, "(\n\n)");
			file = input_array[0];
			if (lengthOf(input_array) > 1)
			{
				alignment_channel = input_array[1];
			}
			else
			{
				// We set this equal to zero to distinguish it later when we
				// determine what channels were acquired. The though is that if
				// no alignment channel is given, then the alignment channel
				// should be determined as the first channel that was actually
				// acquired. This may not always work (say you acquire channel 1
				// but had the PMT off because you only cared about channel 2,
				// yet you forgot to turn off acquisition for 1), but it would be
				// more accurate than hardcoding a channel
				alignment_channel = 0;
			}
			print("File is " + file);
			open(file);

//			saveAs("Tiff", dir1+list[i]+substring(listcurr[20],0,33)+'Ch1');

			fid1 = getImageID();
			selectImage(fid1);
			path = getDirectory("image");
			print("Path is " + path);
			filename = getInfo("image.filename");
			imageDescription = getInfo("image.description");

			if (alignment_channel>0)
			{
				// On the off chance that the desired alignment channel doesn't
				// exist, let the macro find default to the first acquired
				// channel by setting alignment_channel=0
				if (indexOf(imageDescription,
					"acquiringChannel"+alignment_channel+"=1")<0) 
				{
					alignment_channel = 0;
					print("Desired alignment channel wasn't acquired; defaulting to aligning to first acquired channel");
				}
			}

			if (alignment_channel==0)
			{
				if (indexOf(imageDescription, "acquiringChannel1=1")>-1) 
				{
					alignment_channel = "1";
				}
				else if (indexOf(imageDescription, "acquiringChannel2=1")>-1) 
				{
					alignment_channel = "2";
				}
				else
				{
					exit("Something's gone wrong. Apparently nothing was acquired on channel 1 or 2, which should be the only PMT acquisition channels.");
				}
			}

			// Remember we only expect channels 1 and 2 to have data requiring
			// alignment
			if (matches(alignment_channel, "1"))
			{
				alignee_channel = "2";
			}
			else
			{
				alignee_channel = "1";
			}

			if (indexOf(imageDescription,
				"acquiringChannel"+alignee_channel+"=1")<0) 
			{
				alignee_channel = 0;
			}

			ind1 = (indexOf(imageDescription, "acquiringChannel1=1")>-1);
			ind2 = (indexOf(imageDescription, "acquiringChannel2=1")>-1);
			ind3 = (indexOf(imageDescription, "acquiringChannel3=1")>-1);
			ind4 = (indexOf(imageDescription, "acquiringChannel4=1")>-1);
			channelsAcquired = newArray(ind1, ind2, ind3, ind4);
			channelSpacing = 0;
			for (i=0;i<4;i++)
			{
				channelSpacing += channelsAcquired[i];
				if (i<parseInt(alignment_channel))
				{
					alignment_channel_first_frame = channelSpacing;
				}
				if (i<parseInt(alignee_channel))
				{
					alignee_channel_first_frame = channelSpacing;
				}
			}
			print("Spacing is " + channelSpacing);

			getDimensions(junkWidth, junkHeight, junkChannels, slices, junkFrames);
			print("Making substack for channel " + alignment_channel);
			
			run("Make Substack...", " slices="+alignment_channel_first_frame+"-"+slices+"-"+channelSpacing);
			//close();

			fid1 = getImageID();
			selectImage(fid1);
			alignment_channel_filename = path+substring(filename, 0, lengthOf(filename)-4) + "_ch"+alignment_channel+"_disinterleaved";
			print("Saving to " + alignment_channel_filename);
			saveAs("Tiff",alignment_channel_filename);
			print("Saved.");

			print("Aligning...");
			run("Batch Registration DL");
			print("Done aligning Ch"+alignment_channel+" stack");


			// Open the image sequence of Ch2
			if (alignee_channel>0)
			{
				print("Making substack for channel " + alignee_channel);
				run("Make Substack...", " slices="+alignee_channel_first_frame+"-"+slices+"-"+channelSpacing);

				fid1 = getImageID();
				selectImage(fid1);
				alignee_channel_filename = path+substring(filename, 0, lengthOf(filename)-4) + "_ch"+alignee_channel+"_disinterleaved";
				print("Saving to " + alignee_channel_filename);
				saveAs("Tiff",alignee_channel_filename);
				// Align the 2nd stack 
				run("Batch Register to Coords DL");

				print("Done aligning Ch"+alignee_channel+" stack");

				run("Quit");
			}
			else
			{
				run("Quit");
			}


//			fid1 = getImageID();
//			selectImage(fid1);
			//close();
	
			// Align the 2nd stack 
//			run("Batch Register to Coords DL");
//
//			print("done aligning Ch2 stack");
		}
	}
}
