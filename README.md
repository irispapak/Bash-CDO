------------------
M.Sc Thesis Codes:
------------------

This repository contains bash scripts with CDO commands.

The methodology used in the scripts is:
1. It selects common time period for model and observations.
2. It creates an orography correction file for temperature (file that consists of the height difference between model and observations at each grid point multiplied with the lapse rate).
3. It remaps the finer to the coarser grid (EOBs to WRF).
4. It applies the temperature correction to the observations.
5. It calculates the mean monthly values.
6. It splits the whole area to 8 subregions.
7. It calculates the mean monthly values for each subregion.
8. It seperates the results for each season.

