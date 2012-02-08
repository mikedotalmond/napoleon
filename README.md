#Napoleon
*Extending ND2D with physics and more...*

This experiment adds the 2D phyiscs of [Nape][10] and some extra 2D object types to the 2D GPU accelerated [ND2D][9] framework.

To use it you will need to clone (or fork) this repository and my ND2D fork, which can be found [here][1]. 

I use [FlashDevelop][11], so that's the format of the example project file.

Try out the current build of the napoleon example/test project [here.][12] There's info in the [console][6] at the top, but you can close it and use 'n' to skip through the tests if you prefer.
(ctrl+shift+enter to show/hide the console)


The project is still early in development, so things are likely to change and break along the way.

----------

#New for ND2D
- de.nulldesign.nd2d.display.Polygon2D 
- de.nulldesign.nd2d.display.QuadList2D 
- de.nulldesign.nd2d.display.QuadLine2D
- de.nulldesign.nd2d.geom.PolygonData 
- de.nulldesign.nd2d.material.APolygon2DMaterial 
- de.nulldesign.nd2d.material.Polygon2DColorMaterial 
- de.nulldesign.nd2d.material.Polygon2DTextureMaterial 
- de.nulldesign.nd2d.utils.PolyUtils 

#Napoleon
- mikedotalmond.napoleon.INapeNode
- mikedotalmond.napoleon.NapePolygon2D
- mikedotalmond.napoleon.NapeQuad2D
- mikedotalmond.napoleon.NapeScene2D
- mikedotalmond.napoleon.NapeSprite2D
- mikedotalmond.napoleon.NapeWorld2D

----------

#TODO
- More (better) demos / example projects
- More control over Polygon2D vertices
- setVertexPosition(s) for (Nape)Polygon2D
- Sprite-sheet support for Polygon2D (needed?)
- Vertex weighted texture blending for Polygon2DTextureMaterial
- NapeQuadList2D + general compound physics body support
- ?Polygons with holes (composed of convex polys..?) 
- ?Concave Polygon support? (composed of convex polys..?)

----------

#Libraries used

- ND2D 
[https://github.com/mikedotalmond/nd2d][1] (forked from [https://github.com/nulldesign/nd2d][8])

- Nape (swcs included in /lib)
[https://github.com/deltaluca/nape][3]
[http://deltaluca.me.uk/docnew/][4]

- AS3Signals (swc included in /lib)
[https://github.com/robertpenner/as3-signals][5]

- DConsole2 (swc included in /lib)
[https://code.google.com/p/doomsdayconsole/][6]


----------


Delaunay triangulation code - net.nicoptere.delaunay
- [http://en.nicoptere.net/?p=10][7]

Convex hull creation in de.nulldesign.nd2d.utils.PolyUtils was derived from some code by bit-101
- [http://www.bit-101.com/blog/?p=1497][8]


  [1]: https://github.com/mikedotalmond/nd2d
  [2]: https://github.com/nulldesign/nd2d
  [3]: https://github.com/deltaluca/nape
  [4]: http://deltaluca.me.uk/docnew/
  [5]: https://github.com/robertpenner/as3-signals
  [6]: https://code.google.com/p/doomsdayconsole/
  [7]: http://en.nicoptere.net/?p=10
  [8]: http://www.bit-101.com/blog/?p=1497
  [9]: http://www.nulldesign.de/category/experiments/nd2d/
  [10]: https://github.com/deltaluca/nape
  [11]: http://www.flashdevelop.org/
  [12]: http://mikedotalmond.github.com/napoleon/