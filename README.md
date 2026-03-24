MT pipeline for FSL 
GH, last reviewed 14 Feb 2026

Purpose: 
Co-registration of 3D MRI  to individual space in acpc orientation for calculation of MTsat1, T12, and B1+ 3

Data requirements and structure: 
Dicom 2D images converted to NifTi 3D volumes in arbitrary units [a.u.], that is, of consistent scaling (default on Siemens; rescale GE and Philips) reordered to standard transverse orientation (x=RL, y=AP, z=IS)							File names start with an exam identifier [hum_num] with content identifier appended by  “-“ for image data or “_” for maps. 								Volumes of different angulation and resolution are organized in individual sub-directories to exam. 													Target directory /acpc for synopsis of structural and quantitative data.

seg_acpc:
rigid registration of MP-RAGE (-tfl) and optional SPACE (-tse) from /seg using 6 parameter FLIRT to create an individual reference in acpc angulation in /acpc 
mt_acpc: 
rigid registration of MT-weighted (-mt), PD-w (-pd), and T1-w (-t1) from /mt to MP-RAGE in /acpc; brain mask created on –pd using BET, calculation of ‘apparent’ _T1, _A(mplitude); and _MT(sat) maps based on nominal flip angles and TR from masked input (-msk) 
bias_acpc:
calculation of B1+ maps (_bias) from two single-shot STEAM volumes (-tst60) and (-tst110) in /rf, registration to /acpc and correction of _T1 maps to _T1corr. Motion artifacts are mitigated by averaging or exclusion of corrupted volumes

Remark: 
Data organization and processing strategy had been adapted to the limited functionality of fslview. For clinical application see e.g. ref 4.

1.	Helms G, Dathe H, Kallenberg K, Dechent P. High-resolution maps of magnetization transfer with inherent correction for RF inhomogeneity and T1 relaxation obtained from 3D FLASH MRI. Magnetic Resonance in Medicine. Dec 2008;60(6):1396-1407.
2.	Helms G, Dathe H, Dechent P. Quantitative FLASH MRI at 3T using a rational approximation of the Ernst equation. Magnetic Resonance in Medicine. Mar 2008;59(3):667-672.
3.	Helms G, Finsterbusch J, Weiskopf N, Dechent P. Rapid radiofrequency field mapping in vivo using single-shot STEAM MRI. Magnetic Resonance in Medicine. Sep 2008;60(3):739-743.
4.	Dreha-Kulaczewski SF, Brockmann K, Henneke M, Dechent P, Gärtner J, Helms G. Assessment of  myelination in hypomyelinating disorders by quantitative MRI. Journal of Magnetic Resonance Imaging. 2012;36(6):1329-1338.

