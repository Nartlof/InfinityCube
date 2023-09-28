/*
Author: Carlos Eduardo Foltran
Project: Infinity cube toy that requires assembly.
Start: 2023-09-28

*/

// Main cube side
CubeSide = 20;
// Filament diameter (use a piece of filament as hinge axis)
FilDia = 1.75;
// Diameter of the hole in the hinges (increase for a looser fit)
HingeHole = 2;
// Wall thickness
WallThickness = 2;
// Gap between cubes
Gap = 0.4;

// Part to render
PartToRender = "Assembly"; //["Assembly", "Hinge", "Cube 1", "Cube 2", "Cube 3", "Cube 4"]

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;

module MainCube(side = CubeSide, wall = WallThickness, hole = HingeHole, filDia = FilDia, gap = Gap, type = 1)
{
    module mainCube()
    {
        face = side - 2 * fillet;
        hull()
        {
            for (i = [[side, face, face], [face, side, face], [face, face, side]])
                cube(i, center = true);
        }
    }

    module hingeCutOff()
    {
        cutOffHeigth = side - 2 * (fillet + wall) + 2 * gap;
        echo(cutOffHeigth);
        cutOffDiameter = hole + 2 * (wall + gap);
        translate(v = [ (side - cutOffDiameter) / 2 + gap, 0, cutOffDiameter / 2 - gap - side / 2 ])
            rotate([ -90, 0, 0 ]) translate(v = [ 0, 0, -cutOffHeigth / 2 ])
        {
            translate(v = [ 0, 0, -(side - cutOffHeigth - 1) / 2 + fillet ]) cylinder(h = side + 1, d = filDia);
            cylinder(h = cutOffHeigth, d = cutOffDiameter);
            for (i = [-1:1])
            {
                rotate([ 0, 0, i * 90 ]) cube(size = [ cutOffDiameter / 2, cutOffDiameter / 2, cutOffHeigth ]);
            }
        }
    }

    // Defining the appropriated fillet for the geometry
    fillet = wall + hole / 2;
    // mainCube();
    color(c = (type == 1) ? "blue" : (type == 2) ? "red" : (type == 3) ? "green" : "yellow") difference()
    {
        mainCube();
        hingeCutOff();
        if (type == 1)
        {
            rotate([ 180, 0, 90 ]) hingeCutOff();
        }
        else if (type == 2)
        {
            rotate([ 0, 90, 0 ]) rotate([ 0, 0, 90 ]) hingeCutOff();
        }
        else if (type == 3)
        {
            rotate([ -90, 0, 0 ]) rotate([ 0, 0, 180 ]) hingeCutOff();
        }
        else
        {
            rotate([ 180, 0, 270 ]) hingeCutOff();
        }
    }
}

module Hinge(side = CubeSide, wall = WallThickness, hole = HingeHole, filDia = FilDia, gap = Gap, type = 1)
{
    fillet = wall + hole / 2;
    hingeHeigth = side - 2 * (fillet + wall);
    difference()
    {
        union()
        {
            cube([ 2 * fillet + gap, 2 * fillet, hingeHeigth ], center = true);
            for (i = [ -1, 1 ])
                translate([ i * (2 * fillet + gap) / 2, 0, 0 ])
                    cylinder(h = hingeHeigth, d = 2 * fillet, center = true);
        }
        for (i = [ -1, 1 ])
            translate([
                i * (2 * fillet + gap) / 2,
                0,
            ]) cylinder(h = hingeHeigth + 1, d = hole, center = true);
    }
}

// Hinge();

if (PartToRender == "Assembly")
{

    types = [ 1, 2, 3, 4, 4, 3, 2, 1 ];
    rotations =
        [ [ 0, 0, 0 ], [ 3, 0, 0 ], [ 0, 0, 0 ], [ 2, 0, 1 ], [ 0, 2, 1 ], [ 0, 0, 2 ], [ 3, 0, 2 ], [ 0, 0, 2 ] ];

    for (i = [0:3])
        for (j = [0:1])
        {
            translate(v = [ i, j, 0 ] * (CubeSide + Gap)) rotate(rotations[i + 4 * j] * 90) union()
            {
                MainCube(type = types[i + 4 * j]);
                translate(v = [ (CubeSide + Gap) / 2, 0, -(CubeSide - HingeHole) / 2 + WallThickness ])
                    rotate([ 90, 0, 0 ]) Hinge();
            }
        }
}
else if (PartToRender == "Hinge")
{
    Hinge();
}
else if (PartToRender == "Cube 1")
{
    rotate([ 0, -45, 0 ]) MainCube(type = 1);
}
else if (PartToRender == "Cube 2")
{
    rotate([ 135, 0, 0 ]) MainCube(type = 2);
}
else if (PartToRender == "Cube 3")
{
    rotate([ 0, 135, 0 ]) MainCube(type = 3);
}
else if (PartToRender == "Cube 4")
{
    rotate([ 225, 0, 0 ]) MainCube(type = 4);
}