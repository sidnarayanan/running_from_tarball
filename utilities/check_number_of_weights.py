from DataFormats.FWLite import Events, Handle
import ROOT
from math import pi, sqrt, copysign
from ROOT import TH1F, TFile, TTree, TString, gSystem, gROOT, AddressOf, TLorentzVector, TVector, TMath
import sys 
import os
import numpy as np
#cmsswbase = TString.getenv("CMSSW_BASE")

print 'Loading FW Lite setup.\n'
gSystem.Load("libFWCoreFWLite.so") 
ROOT.AutoLibraryLoader.enable()
gSystem.Load("libDataFormatsFWLite.so")
gSystem.Load("libDataFormatsPatCandidates.so")

#from ROOT import TreeStruct

events = Events (sys.argv[1])
weighthandle = Handle ('LHEEventProduct')
weightlabel = ("source")

evt_i = 0
stat_i = 0

#Loop through all events
number_of_weights = 0

for event in events:
        if evt_i > 0:
                break

        #Fill LHE event weights
        event.getByLabel(weightlabel,weighthandle)      
        Weightvector = weighthandle.product()
	#print Weightvector.weights().size()
	number_of_weights = Weightvector.weights().size()
	
	evt_i = evt_i + 1



if number_of_weights != int(sys.argv[2]):
	print number_of_weights
	print sys.argv[2]
	os.system('rm -f %s' % sys.argv[1])
else:
	os.system('mv %s %s' % (sys.argv[1], sys.argv[1].replace('.root','_X.root')))


