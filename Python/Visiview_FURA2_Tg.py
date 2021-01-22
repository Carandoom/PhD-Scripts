#
#	Python
#	
#	Visiview script to automatically change the time interval
# Usually used with FURA2 dye and Thapsigargin protocol 
# in calcium free medium followed by calcium addition
#	
#	Christopher Henry - V1 - 2019-10-06
#


# To change every dish
BaseNameFURA = '2019-10-06_Dish001-'
#To change only at the beginning of the experiment
BaseNameGFP = '2019-10-06_Dish00'
Directory = 'D:\USER_DATA\Christopher\\2019-10-06_HEKwt_'


# Snapshot of Green channel with our GFP protocol set at 300 ms exposure
VV.Acquire.WaveLength.Series = False
VV.Acquire.WaveLength.Count = 1
VV.Acquire.WaveLength.Illumination = 'GFP'
VV.Acquire.SetExposureTime(300,'ms')
VV.Acquire.Binning = 4
VV.Acquire.TimeLapse.Series = False
VV.Acquire.Sequence.BaseName = BaseNameGFP
VV.Acquire.Sequence.Directory = Directory
VV.Acquire.Sequence.SaveToDisk = True
VV.Acquire.Sequence.Start()

# Wait for the end of the sequence recording
VV.Macro.Control.WaitFor('VV.Acquire.Sequence.IsRunning','==',0)

# Protocol 1 - FURA2 - 1 picture every 10 sec for 72 timepoints
VV.Acquire.WaveLength.Series = True
VV.Acquire.WaveLength.Count = 2
VV.Acquire.WaveLength.Current = 1
VV.Acquire.WaveLength.Illumination = 'Fura2-low340nm'
VV.Acquire.SetExposureTime(500,'ms')
VV.Acquire.Binning = 4
VV.Acquire.WaveLength.Current = 2
VV.Acquire.WaveLength.Illumination = 'Fura2-high380nm'
VV.Acquire.SetExposureTime(200,'ms')
VV.Acquire.Binning = 4
VV.Acquire.TimeLapse.Series = True
VV.Acquire.TimeLapse.SetTimeInterval(10,'sec')
VV.Acquire.TimeLapse.TimePoints = 72
VV.Acquire.Sequence.BaseName = BaseNameFURA
VV.Acquire.Sequence.Directory = Directory
VV.Acquire.Sequence.SaveToDisk = True
VV.Acquire.Sequence.Start()

VV.Macro.Control.WaitFor('VV.Acquire.Sequence.IsRunning','==',0)


# Protocol 2 - FURA2 - 1 picture every 3 sec for 150 timepoints
VV.Acquire.WaveLength.Series = True
VV.Acquire.WaveLength.Count = 2
VV.Acquire.WaveLength.Current = 1
VV.Acquire.WaveLength.Illumination = 'Fura2-low340nm'
VV.Acquire.SetExposureTime(500,'ms')
VV.Acquire.Binning = 4
VV.Acquire.WaveLength.Current = 2
VV.Acquire.WaveLength.Illumination = 'Fura2-high380nm'
VV.Acquire.SetExposureTime(200,'ms')
VV.Acquire.Binning = 4
VV.Acquire.TimeLapse.Series = True
VV.Acquire.TimeLapse.SetTimeInterval(3,'sec')
VV.Acquire.TimeLapse.TimePoints = 150
VV.Acquire.Sequence.BaseName = BaseNameFURA
VV.Acquire.Sequence.Directory = Directory
VV.Acquire.Sequence.SaveToDisk = True
VV.Acquire.Sequence.Start()

VV.Macro.Control.WaitFor('VV.Acquire.Sequence.IsRunning','==',0)


# Just a GFP protocol to use for next dish - nothing to run
VV.Acquire.WaveLength.Series = False
VV.Acquire.WaveLength.Count = 1
VV.Acquire.WaveLength.Illumination = 'GFP'
VV.Acquire.SetExposureTime(300,'ms')
VV.Acquire.Binning = 4
VV.Acquire.TimeLapse.Series = False
VV.Acquire.Sequence.BaseName = BaseNameGFP
VV.Acquire.Sequence.Directory = Directory
VV.Acquire.Sequence.SaveToDisk = True
