
## Replacer Modes

Situation: the player points at a node and wants to use the replacer. <br/>
* Bright blue: the ray of sight and pointed thing above and under
* Different nodes:
  * White: air
  * Dark grey: a solid node which should be replaced
  * Brown: another solid node adjacent to the grey one
  * Yellow green: a translucent node, such as leaves or glass
  * Red (in later pictures): the node which the replacer (re)places
* The black thing: it should depict an eye for the camera position.
![replacer_template](https://user-images.githubusercontent.com/3192173/74016149-36b36200-4992-11ea-86d1-2d3b64035557.png)



### Single Mode

Left click:
![replacer_single_leftclick](https://user-images.githubusercontent.com/3192173/74015937-e1775080-4991-11ea-912b-4f4e75c53918.png)

Right click:
![replacer_single_rightclick](https://user-images.githubusercontent.com/3192173/74015939-e20fe700-4991-11ea-9e4d-8f8c8900024d.png)

### Field Mode

The replacer changes nodes in a 2D slice (it is 1D in these illustrations).
Left click:
![replacer_field_leftclick](https://user-images.githubusercontent.com/3192173/74015955-e63c0480-4991-11ea-95b9-4b312bc62ed1.png)
Right click:
![replacer_field_rightclick](https://user-images.githubusercontent.com/3192173/74015933-e0deba00-4991-11ea-8321-de9c0499dcf3.png)

### Crust Mode

Left click: the replacer changes visually adjacent nodes (of the same type) on a surface
![replacer_crust_leftclick](https://user-images.githubusercontent.com/3192173/74015951-e5a36e00-4991-11ea-8cdf-f8b1c8897da9.png)

Right click: the replacer places nodes onto the surface so that the surface below it is hidden; the added crust can be bounded by other solid nodes but not translucent nodes
![replacer_crust_rightclick](https://user-images.githubusercontent.com/3192173/74015954-e63c0480-4991-11ea-956c-ee6848c182be.png)

