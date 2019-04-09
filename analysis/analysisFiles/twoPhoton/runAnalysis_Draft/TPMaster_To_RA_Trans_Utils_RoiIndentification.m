function roiMethod_for_twoPhotonMaster = TPMaster_To_RA_Trans_Utils_RoiIndentification(roiMethod_for_RunAnalysis)
switch roiMethod_for_RunAnalysis
    case 'IcaRoiExtraction'
        roiMethod_for_twoPhotonMaster = 'ICA_DFOVERF';
    case 'HHCARoiExtraction'
         roiMethod_for_twoPhotonMaster = 'HHCA';
end
    
end