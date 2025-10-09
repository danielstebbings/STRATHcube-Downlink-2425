import itur.models.itu676 as itu676
import itur

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

import math
import scipy.optimize
from sigfig import round


def main():
    print("Hello from itu-models!")
    print("VERSION: ", itu676.get_version())

    frequency = 437/1000
    # 55.86185353704944, -4.245785968697969
    jw_lat  = 55.86185353704944
    jw_long = -4.245785968697969

    g_rx = 15.5
    d_rx = ((3*10**8) / (frequency*10**9)) * 10**((15.5-10*math.log10(6))/20)
    p_exceeded = 0.1
    height_rx = 70

    angles = list(range(10,95,5))
    atmo_atts = [np.float64]*len(angles)
    for i,angle in enumerate(angles):
        
        (Ag, Ac, Ar, As, A) = itur.atmospheric_attenuation_slant_path(
            lat=jw_lat,
            lon=jw_long,
            f=frequency,
            el=angle,
            p=p_exceeded,
            D=d_rx,
            hs=height_rx/1000, # km
            mode="exact",
            return_contributions=True,
        )

        
        atmo_atts[i]  = {"Angle_deg":angle,"Gaseous_dB": Ag.value, "Cloud_dB":Ac.value, "Rain_dB":Ar.value, "Scintillation_dB":As.value, "Total_dB":A.value}
        print("ANGLE: ", angle,"Gaseous: ", Ag.value, " dB ", "Total Atmospheric: ",A.value, " dB")
    #print(atmo_atts)
    df = pd.DataFrame(atmo_atts)
    df.to_csv("Atmospheric_Attenuation.csv",index=False)

    plt.figure()
    plt.plot(angles, [atts["Total_dB"] for atts in atmo_atts], marker='o', label='Calculated')
    #plt.plot(angles, p_vals,    marker='x', label="Polyfit: "+str(round(a,sigfigs=2))+" "+str(round(b,sigfigs=2))+" "+str(round(c,sigfigs=2)))
    plt.xlabel('Elevation Angle (degrees)')
    plt.ylabel('Atmospheric Attenuation (dB)')
    plt.title('Atmospheric Attenuation vs Elevation Angle')
    plt.legend()
    plt.grid(True)
    plt.show()

if __name__ == "__main__":
    main()
