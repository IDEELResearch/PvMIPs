setwd("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/")
library(tidyverse)
library(readxl)
library(sf)
library(ggrepel)
library(rnaturalearth)
library(rnaturalearthdata)
library(ggspatial)
#library(nominatimlite)
library(osmdata)
library(cowplot)

#############################################################################################
#1. Load shapefiles for country of focus 
#    Note that a single shapefile includes 4 core files.
#    Most GIS programs need all to correctly load a shapefile, in R just read in the .shp file.
#    My preferred source for country shapefiles is gadm.org, they provide complete sets of various administrative boundaries
#    Conventionally, PER_0=country boundary, PER_1=state boundaries, PER_2=county boundaries, PER_3=municipal boundaries, or analogous
#############################################################################################

per0<-st_read("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/gadm41_PER_0.shp") #This file is a spatial dataframe, it includes variables like NAME to subset if needed, for mapping, "geometry" is what will be used

#quick plot to view country shapefile
plot(per0$geometry)

#can load other administrative boundaries

#get admin shape file from naturalearth
#admin10 <- ne_download(scale="large", type = "admin_1_states_provinces",
   #                    category = "cultural", returnclass = "sf")
rivers10 <- ne_download(scale = 10, type = 'rivers_lake_centerlines', 
                        category = 'physical', returnclass = "sf")
lakes10 <- ne_download(scale = "medium", type = 'lakes', 
                       category = 'physical', returnclass = "sf")
oceans10 <- ne_download(scale = "medium", type = "coastline",
                        category = 'physical', returnclass = "sf")
sov110 <- ne_download(scale="medium", type = "sovereignty",
                      category = "cultural", returnclass = "sf") |> subset(CONTINENT == "South America")
SAm <- ne_countries(scale="medium", type = "sovereignty", continent = "South America", returnclass = "sf")

pop_places <- ne_download(scale = "large", type =  "populated_places", category = "cultural", returnclass = "sf")

per1 <- st_read("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/gadm41_PER_1.shp")
per3 <- st_read("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/gadm41_PER_3.shp")
#Lima <- dplyr::filter(per3, NAME_3 == "Lima")
#Iquitos <- dplyr::filter(per3, NAME_3 == "Iquitos")

inset_cities  <- opq(bbox = "Maynas, Loreto, Peru") |> add_osm_feature(key = "name", value = c("San Juan Bautista", "Belén", "Iquitos", "Punchana", "Indiana"), value_exact = TRUE) |>
  osmdata_sf()


##############################################################################################
#2. Read in coordinates for study sites and other study datasets
#############################################################################################

#study_coords <- read_xlsx("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/NAMRU_by_city.xlsx") |>
#  filter(!is.na(Lat))%>%  #Remove any locations missing coordinates
#  distinct(Lat, Long, .keep_all = T)%>%  #subset to unique locations only
#  st_as_sf(coords = c("Long","Lat"), remove=F, crs = 4326)  

#The st_as_sf step transforms the numeric lat and long coordinates into a geometry object. 
#The crs call specifies that the coordinates are in lat/long units, it is important that the order for coords=c() is Long, then Lat
#Personal preference, I like to keep the original Lat and Long values as it makes for easier plotting with ggplot()


#Can subset to geometry only and write to file if wanted, this is useful for mapping in other GIS software
#study_coords%>%
#  dplyr::select(geometry)%>%
#  st_write("./per_study_coords.gpkg")

study_coords <- read_xlsx("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/NAMRU_by_city.xlsx")

#subset regions in shapefile to only those in the study
study_regions<-unique(study_coords$State)

pe_study_regions<-per1%>%
  filter(NAME_1%in%study_regions)

#cities <- per3 |> filter(NAME_3 %in% study_coords$City)

#by <- join_by(City == NAME_3)

#study_coords <- study_coords |> right_join(per3, by)

#Check out locations of study coordinates within boundary of PERU

plot(per0$geometry)
#plot(study_coords$geometry, add=T)

#Looks like all study sites are inside of the country--good sign!

######
#Read in study data and join with coordinates by study site name?
study_dat <- read_xlsx("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/Copy of MDP_Jeff_filteredDB.xlsx")

study_dat$City = ""

Alto_Nanay <- list("DIAMANTE AZUL")
for (var in Alto_Nanay) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Alto Nanay"
}

Belen <- list("PADRECOCHA", "PROGRESO")
for (var in Belen) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Belén"
}

Indiana <- list("SAN LUIS", "SANTA ROSA")
for (var in Indiana) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Indiana"
}

Iquitos <- list("FRAY MARTIN", "IQUITOS", "LAGUNAS", "MANACAMIRI", "SANTA RITA")
for (var in Iquitos) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Iquitos"
}

Mazan <- list("PUERTO ALEGRE")
for (var in Mazan) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Mazán"
}

Napo <- list("SANTA MARIA")
for (var in Napo) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Napo"
}

Nauta <- list("NAUTA")
for (var in Nauta) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Nauta"
}

Pardo_Miguel <- list("YARINAL")
for (var in Pardo_Miguel) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Pardo Miguel"
}

Pichanaqui <- list("MILAGRO")
for (var in Pichanaqui) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Pichanaqui"
}

Punchana <- list("CENTRO FUERTE", "FLOR DE AGOSTO", "MOMONCILLO", "NUEVA YORK", "NUEVO SAN ANTONIO", "PORVENIR", "PUERTO ALICIA", "SAN ANDRES", "SANTO TOMAS", "GEN GEN")
for (var in Punchana) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Punchana"
}

Ramon_Castilla <- list("CABALLOCOCHA", "VISTA ALEGRE")
for (var in Ramon_Castilla) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Ramón Castilla"
}

San_Juan_Bautista <- list("LLANCHAMA", "NINARUMI", "NUEVA VIDA", "PUERTO ALMENDRA", "QUISTOCOCHA", "SAN JUAN", "SANTA CLARA", "ZUNGAROCOCHA")
for (var in San_Juan_Bautista) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "San Juan Bautista"
}

Tigre <- list("NUEVO RETIRO")
for (var in Tigre) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Tigre"
}

Torres_Causana <- list("PUERTO ELVIRA")
for (var in Torres_Causana) {
  print(var)
  study_dat$City[grepl(var, study_dat$Community)] <- "Torres Causana"
}

study_dat$Region = ""

Chanchamayo <- list("Pichanaqui")
for (var in Chanchamayo) {
  print(var)
  study_dat$Region[grepl(var, study_dat$City)] <- "Chanchamayo"
}

Loreto <- list("Tigre")
for (var in Loreto) {
  print(var)
  study_dat$Region[grepl(var, study_dat$City)] <- "Loreto"
}

Mariscal_Ramon_Castilla <- list("Ramón Castilla")
for (var in Mariscal_Ramon_Castilla) {
  print(var)
  study_dat$Region[grepl(var, study_dat$City)] <- "Mariscal Ramón Castilla"
}

Maynas <- list("Alto Nanay", "Belén", "Indiana", "Iquitos", "Mazán", "Napo", "Nauta", "Punchana", "San Juan Bautista", "Torres Causana")
for (var in Maynas) {
  print(var)
  study_dat$Region[grepl(var, study_dat$City)] <- "Maynas"
}

Rioja <- list("Pardo Miguel")
for (var in Rioja) {
  print(var)
  study_dat$Region[grepl(var, study_dat$City)] <- "Rioja"
}

study_dat$State = ""

Junin <- list("Chanchamayo")
for (var in Junin) {
  print(var)
  study_dat$State[grepl(var, study_dat$Region)] <- "Junín"
}

Loreto <- list("Loreto", "Mariscal Ramón Castilla", "Maynas")
for (var in Loreto) {
  print(var)
  study_dat$State[grepl(var, study_dat$Region)] <- "Loreto"
}

San_Martin <- list("Rioja")
for (var in San_Martin) {
  print(var)
  study_dat$State[grepl(var, study_dat$Region)] <- "San Martín"
}

inset_cities_df <- inset_cities$osm_multipolygons |> as.data.frame() |> select(name, geometry) |> rename("City" = "name")

#inset_by <- join_by("City" == "name")

inset_dat <- study_dat |> subset(City == c("San Juan Bautista", "Belén", "Iquitos", "Punchana", "Indiana")) |> left_join(inset_cities_df)

study_dat <- study_dat |> left_join(study_coords, by="City")


##############################################################################################
#3. Create prevalence dataset and generate summary maps
##############################################################################################

pvcounts<-study_dat%>%
  filter(!is.na(City))%>%
  group_by(City, Lat, Long)%>%
  summarize(n_pv=sum(Species == "Pv", na.rm = T)) |>
  subset(City != "Mazán" & City != "Nauta" & City != "Pardo Miguel" & City != "Torres Causana") #removing cities that lack data in later analyses
  #summarise(n_tested=sum(tested, na.rm=T), n_pf=sum(pf, na.rm=T), pf_pct_prev=(n_pf/n_tested)*100) #I just made up variables here, replace with correct names

inset_counts <- inset_cities_df |> left_join(pvcounts)

pe_study_regions <- pe_study_regions |> subset(NAME_1 != "San Martín") #removing San Martín for the same reason as above

#inset_box <- data.frame(x = c(-74.25, -72.5, -74.25,-72.5), y = c(-4.5, -4.5, -3.25, -3.25))

#Plot in ggplot()
#Map of Pv samples per study site with size of dot proportional to number of samples tested
full_map <- ggplot()+
  geom_sf(data = SAm, fill = "gray96") +
  geom_sf(data = per1, fill = "gray90", lwd = 0.1) +
  geom_sf(data = pe_study_regions, fill = "gray80") +
  geom_sf(data = lakes10, fill = "aliceblue") +
  geom_sf(data = rivers10, color ="dodgerblue3", alpha = 0.3) +
  #geom_sf(data = Iquitos, fill = "black") +
  #geom_point(aes(x = -77, y = -12), fill = "black") +
  #geom_sf(data=per0, fill="grey96")+  #Use geom_sf for plotting spatial polygons, aes automatically maps to "geometry", otherwise use aes(geometry=geometry)
  geom_point(data=pvcounts, aes(x=Long, y=Lat, size=n_pv), shape=21, alpha=1, fill = "red")+
  labs(size = "# of Samples") +
  
  #geom_sf(data = Lima, fill = "black") +
  #geom_sf_text(data = Lima, aes(label = "Lima"), nudge_x = -1, size = 3) +

  #geom_sf_text(data = Iquitos, aes(label = NAME_3), nudge_x = -1.25, nudge_y = -0.5, size = 3) +
  #scale_size(breaks = c(10, 50, 100, 200), name="Pv Infections")+  #modify breaks as needed
  #scale_fill_distiller(palette="Blues", name="P.f. prevalence\n(%)", direction=1, limits=c(0, 100))+
  #geom_text_repel(data=pvcounts, aes(x=Long, y=Lat, label= City), alpha=0.8, max.overlaps = Inf, box.padding = 0.5, point.padding = 0.6)+
  coord_sf(xlim = c(-82, -66), ylim = c(-20, 1), expand = F, default_crs = sf::st_crs(4326)) +
  
  ggtitle(expression(paste(italic("P. vivax "), "Sample Collections")))+
  annotation_scale(location = "bl", width_hint = 0.25) +
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.85, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering)+
  annotate("text", x = -78, y = -0.1, label = "Ecuador", 
           color="grey30", size=4 , fontface="italic") +
  annotate("text", x = -72.7, y = 0, label = "Colombia", 
           color="grey30", size=4 , fontface="italic") +
  annotate("text", x = -68, y = -2, label = "Brazil", 
           color="grey30", size=6 , fontface="italic") +
  annotate("text", x = -67.7, y = -15, label = "Bolivia", 
           color="grey30", size=5 , fontface="italic") +
  annotate("text", x = -69.6, y = -19, label = "Chile", 
           color="grey30", size=3 , fontface="italic") +
  theme(panel.background = element_rect(fill = 'aliceblue', colour = 'grey97')) +
  theme(axis.ticks = element_blank(),
        
        axis.text.x = element_blank(),
        
        axis.text.y = element_blank()) +
  xlab("") +
  
  ylab("") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  theme(panel.grid.major = element_line(colour = "transparent")) +
  geom_rect(aes(xmin = -74.25, ymin = -4.5, xmax = -72.5, ymax = -3.25), color = "black", linewidth = 0.25, linetype = 1, alpha = 0.5, fill = NA) 
  #geom_polygon(data = inset_box, aes(x, y, group = 1), fill = NA, color = "black")
  

#full_map + coord_sf(ylim = c(-4.6,-3), xlim = c(-74, -73), expand = F) + theme_linedraw() + geom_text_repel(data = pvcounts, aes(x = Long, y = Lat, label = City), alpha = 0.8, max.overlaps = Inf, box.padding = 0.5, point_padding = 0.6)

inset_map <- ggplot() +
  geom_sf(data = SAm, fill = "gray96") +
  geom_sf(data = per1, fill = "gray90", lwd = 0.1) +
  geom_sf(data = pe_study_regions, fill = "gray80") +
  geom_sf(data = lakes10, fill = "dodgerblue3") +
  geom_sf(data = rivers10, color ="dodgerblue3", alpha = 0.5) +
  geom_sf(data = inset_counts, aes(geometry = geometry, fill = n_pv)) +
  scale_fill_distiller(type="seq", palette = "Reds", direction = 1, name="Samples")+
  #theme(legend.key.size = unit(2, "mm")) +
  #theme(legend.title = element_text(size = 6)) +
  #theme(legend.text = element_text(size = 5)) +
  #geom_sf_text(data = inset_counts, aes(label = City, geometry = geometry), alpha = 0.8, size = 2) +
  coord_sf(xlim = c(-74.25, -72.5), ylim = c(-4.5, -3.25), expand = F) +
  ggtitle(expression(paste("Iquitos and Suburbs")))+
  #annotation_scale(location = "bl", width_hint = 0.25) +
  #theme(panel.background = element_rect(fill = 'aliceblue', colour = 'grey97')) +
  annotate("text", x = -73.2, y = -3.79, label = "Belén", 
           color="black", size=4 , fontface="italic", angle = '45') +
  annotate("text", x = -72.9, y = -3.85, label = "Indiana", 
           color="black", size=4 , fontface="italic") +
  annotate("text", x = -73.4, y = -3.76, label = "Iquitos", 
           color="black", size=4 , fontface="italic", angle = '30') +
  annotate("text", x = -73.4, y = -3.6, label = "Punchana", 
           color="black", size=4 , fontface="italic") + #angle with -30 if need be
  annotate("text", x = -73.55, y = -4.08, label = "San Juan Bautista", 
           color="black", size=4 , fontface="italic", angle = '45') +
  theme(axis.ticks = element_blank(),
        
        axis.text.x = element_blank(),
        
        axis.text.y = element_blank()) +
  xlab("") +
  
  ylab("") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  theme(panel.grid.major = element_line(colour = "transparent")) #+
  #theme(plot.margin=unit(c(t = 0.005, r = 0.005, b = -0.199, l = -0.199), "null")) +
  #theme(legend.margin = margin(0, 0, 0, 0)) +
  #theme(legend.position = c(0.101,0.69)) +
  #theme(plot.background = element_rect(color = 1, size = 1))

#map_with_inset <- ggdraw(full_map) +
#  draw_plot(full_map) +
#  draw_plot(inset_map, x = 0.5, y = 0.52, width = 0.18, height = 0.18)
  #draw_plot(inset_map, x = 0.475, y = 0.5, width = 0.2, height = 0.2)

#maybe actually better to do an inset with the actual boundaries and numbers? Would be easier to label

ggsave("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/full_map.png", full_map, dpi=600, width=6, height=5, units = "in")

ggsave("C:/Users/zpopkinh/OneDrive - University of North Carolina at Chapel Hill/Pvivax MIP Design/Analysis/inset_map.png", inset_map, dpi=600, width=6, height=5, units = "in")

library(patchwork)

full_map + inset_map +
  plot_layout(ncol = 2, nrow = 1) +
  plot_annotation(tag_levels = "A")

ggsave("Fig1_map.png", dpi = 600, width = 12, height = 5, units = "in")

ggsave("Fig1_map.svg", dpi = 600, width = 12, height = 5, units = "in")