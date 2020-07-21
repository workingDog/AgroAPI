# Swift OpenWeather Agro API library

[**OpenWeather Agro API**](https://agromonitoring.com/) brings satellite images to farmers. 
"Through our simple and fast API, you can easily get multi-spectrum images of the crop for the most recent day or for a day in the past; we have the most useful images for agriculture such as NDVI, EVI, True Color and False Color."

**AgroApi** is a small Swift library to connect to the [**OpenWeather Agro API**](https://agromonitoring.com/api) and retrieve the chosen data. Made easy to use with SwiftUI.

Includes, the Polygons and Satellite Imagery APIs.

#### Polygons API

Polygons API provides for polygon creation, adding data, removing a polygon and listing info about one or more polygons. 
You can also retreive the list of your polygons from your account page.

Reference: [Polygons Imagery](https://agromonitoring.com/api/polygons)

#### Satellite Imagery API

After the creation of polygons, the satellite imagery can be used for retreiving images for those polygons, such as; 
images in True Color, False Color, NDVI, and EVI in png, get meta data for your polygon or image in tiff.

Reference: [Satellite Imagery](https://agromonitoring.com/api/images)


### Usage

All interactions with the Agro API server is done through the use of a single **AgroProvider**.

Data, such as satellite imagery from  [**Agro API**](https://agromonitoring.com/api) is accessed through the **AgroProvider**, 
using a set of simple functions, for example:

    import AgroApi
    
    struct ContentView: View {
        let agroProvider = AgroProvider(apiKey: "your key")
        @State var uiImage = UIImage()
        
        var body: some View {
            Image(uiImage: uiImage).onAppear { self.loadData() }
        }
        
        func loadData() {
           let options = AgroOptions(polygon_id: "5f45273c734b52667be0bb1e",
                              start: Date().addingTimeInterval(-60*60*24*20).utc,
                              end: Date().utc)
    
           agroProvider.getImagery(options: options) { imagery in
              if let sat = imagery?.first, let img = sat.image, let theUrl = img.ndvi {
                 self.agroProvider.getPngUIImage(urlString: theUrl, paletteid: 1, reponse: self.$uiImage)
              }
          }
       }
    }
   

See [*AgroApiExample*](https://github.com/workingDog/AgroApiExample) for an example use.


### Installation

Include the files in the **./Sources/AgroApi** folder into your project or preferably use **Swift Package Manager**. 

#### Swift Package Manager  (SPM)

Create a Package.swift file for your project and add a dependency to:

    dependencies: [
      .package(url: "https://github.com/workingDog/AgroApi.git", from: "0.1.0")
    ]

#### Using Xcode

    Select your project > Swift Packages > Add Package Dependency...
    https://github.com/workingDog/AgroApi.git

Then in your code:

    import AgroApi
    

### References

-    [**OpenWeather Agro API**](https://agromonitoring.com/api)


### Requirement

Requires a valid OpenWeather key, see:

-    [OpenWeather how to start](https://openweathermap.org/appid)

### License

MIT
