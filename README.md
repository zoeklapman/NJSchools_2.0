# My First iOS App Version 2.0

## Introduction

This is my first iOS App from my CSSE337 Enterprise Mobile Apps class for college. This is the second version. Here was the objective of the assignment:

> The primary goal of this assignment is develop a mapping app that shows the K-12 schools on a map and tracks the app users location. The app should be modeled similar to MapProject app demonstrated in class, but with data from your homework 2. The secondary goal is to make Homework 2 app as TabBarController interface where the first tab bar is the 2 MVC app, and the second tab bar will be the mapping MVC from above. The extra credit feature is to segue from the MapView to the Detailed ViewController developed in Homework 2 to update the ratings. Upon return from the updated ratings, showcase the changed school marker icon on map to a star if the ratings is 5 stars.

## Description

I took my first iOS app and updated it so there is a map feature in another tab after implementing a UITabBarController. The list of schools in New Jersey are marked on a map using UIMapKit. Clicking on a school provides the option to segue to the school’s detail page to update the school’s ranking. If the user sets the school ranking to 5 stars, the pin image for the school will change from a building to a star.

![NJSchools2.0_List](/Images/NJSchools2.0_List.png)
![NJSchools2.0_Map](/Images/NJSchools2.0_Map.png)
![NJSchools2.0_Detail](/Images/NJSchools2.0_Detail.png)
