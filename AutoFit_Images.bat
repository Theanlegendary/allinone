@echo off
title Auto-Fit Pasted Excel Images
cd /d "%~dp0"
echo Processing images in All_Post_Offices_Image_Template.xlsx...
python autofit_excel_images.py "All_Post_Offices_Image_Template.xlsx"
pause
