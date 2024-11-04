local function info()

    dir = getDir(VolvoC303);

    loadVehicleModel("Vehicles_VolvoC303",

    dir.."/media/models/Vehicles_VolvoC303.txt",

    dir.."/media/textures/Vehicles/Vehicle_VolvoC303_Shell.png");

   

    VehicleDistributions[1].VolvoC303 =  {

        Normal = VehicleDistributions.Normal,

        Specific = { VehicleDistributions.Groceries, VehicleDistributions.Carpenter, VehicleDistributions.Farmer, VehicleDistributions.Electrician, VehicleDistributions.Survivalist, VehicleDistributions.Clothing, VehicleDistributions.ConstructionWorker, VehicleDistributions.Painter },

    }

    ISCarMechanicsOverlay.CarList["Base.VolvoC303"] = {imgPrefix = "smallcar_", x=10,y=0};

    VehicleZoneDistribution.parkingstall.vehicles["Base.VolvoC303"] = {index = -1, spawnChance = 30};

end


Events.OnInitWorld.Add(info);