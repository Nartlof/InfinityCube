/**
 * Project Name: Infinity cube
 *
 * Author: Carlos Eduardo Foltran
 * GitHub: https://github.com/Nartlof/InfinityCube
 * Thingiverse: https://www.thingiverse.com/thing:6249758
 * License: Creative Commons CC0 1.0 Universal (CC0 1.0)
 * Description: Infinity cube toy that requires assembly and can be made with mixed collors.
 *
 * Date Created: 2023-09-28
 * Update: 2023-10-01
 * Last Updated: 2023-10-04
 *
 * This OpenSCAD file is provided under the Creative Commons CC0 1.0 Universal (CC0 1.0) License.
 * You are free to use, modify, and distribute this design for any purpose, without any restrictions.
 *
 * For more details about the CC0 license, visit: https://creativecommons.org/publicdomain/zero/1.0/
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
// Extra space on the holes
HoleGap = 0.4;

// Part to render
PartToRender = "Assembly"; //["Assembly", "All", "All tight", "Cube 1", "Cube 2", "Cube 3", "Cube 4", "Hinge"]

// Create hinge with individual cubes
AddHinge = true;

$fa = ($preview) ? $fa : 2;
$fs = ($preview) ? $fs : .2;

module MainCube(side = CubeSide, wall = WallThickness, hole = HingeHole, filDia = FilDia, gap = Gap, holeGap = HoleGap,
                type = 1)
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

    // The mark parameter tells if it is the hinge to be assembled first
    module hingeCutOff(mark = false)
    {
        cutOffHeigth = side - 2 * (fillet + wall) + 2 * gap;
        cutOffDiameter = hole + 2 * (wall + gap);
        expandedFilDia = filDia + holeGap;
        translate(v = [ (side - cutOffDiameter) / 2 + gap, 0, cutOffDiameter / 2 - gap - side / 2 ])
            rotate([ -90, 0, 0 ]) translate(v = [ 0, 0, -cutOffHeigth / 2 ])
        {
            // Cuttoff for the fillament inserted as hinge axis
            translate(v = [ 0, 0, -(side - cutOffHeigth - 1) / 2 + fillet ]) union()
            {
                cylinder(h = side + 1, d = expandedFilDia);
                // Putting a truncated part on the end to hold the fillament by friction
                rotate([ 180, 0, 0 ]) difference()
                {
                    cylinder(h = expandedFilDia, d = expandedFilDia, center = false);
                    rotate([ 0, 0, 225 ]) translate(v = [ -expandedFilDia / 2, expandedFilDia / 2, 0 ])
                        rotate([ 45, 0, 0 ]) cube([ expandedFilDia, expandedFilDia, 2 * expandedFilDia ]);
                }
            }
            // Round part
            cylinder(h = cutOffHeigth, d = cutOffDiameter);
            // The marking for assembly
            if (mark)
            {
                rotate([ 0, 0, 225 ]) translate(v = [ cutOffDiameter / 2, 0, cutOffHeigth / 2 ])
                    sphere(d = min(wall, cutOffHeigth));
            }
            // Square part
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
        hingeCutOff(mark = true);
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

module Hinge(side = CubeSide, wall = WallThickness, hole = HingeHole, gap = Gap, holeGap = HoleGap)
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
            ]) cylinder(h = hingeHeigth + 1, d = hole + holeGap, center = true);
    }
}

// Main part
// This part of the code just put parts on a apropriated position for printing

module RotatedCube(type = 1, addHinge = AddHinge)
{
    Rotations = [ [ 0, -45, 0 ], [ 180, 45, 0 ], [ 0, 135, 180 ], [ 0, -45, 0 ] ];
    translate([ 0, 0, (CubeSide - (WallThickness + HingeHole / 2)) * sqrt(2) / 2 ]) rotate(Rotations[type - 1])
        MainCube(type = type);

    if (addHinge)
    {
        translate(v = [
            Gap + WallThickness + HingeHole / 2 + (CubeSide - WallThickness - HingeHole / 2) * sqrt(2) / 2, 0,
            (CubeSide - 4 * WallThickness - HingeHole) / 2
        ]) rotate([ 0, 0,
                    90 ]) Hinge(side = CubeSide, wall = WallThickness, hole = HingeHole, gap = Gap, holeGap = HoleGap);
    }
}

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
else if (PartToRender[0] == "C")
{
    RotatedCube(type = ord(PartToRender[5]) - 48, addHinge = AddHinge);
}
else if (PartToRender == "All tight")
{
    for (i = [0:7])
    {
        translate(v = [

            floor(i / 3) *
                (sqrt(2) * (CubeSide - WallThickness - HingeHole / 2) + 2 * WallThickness + HingeHole + 2 * Gap),
            i % 3 * (CubeSide + WallThickness), 0
        ]) RotatedCube(type = i % 4 + 1);
    }
}
else if (PartToRender == "All")
{
    for (i = [0:1])
        for (j = [0:3])
        {
            translate(v = [
                j * (CubeSide + WallThickness),
                i * (sqrt(2) * (CubeSide - WallThickness - HingeHole / 2) + 2 * WallThickness + HingeHole + 2 * Gap), 0
            ]) rotate([ 0, 0, 90 ]) RotatedCube(type = j + 1);
        }
}