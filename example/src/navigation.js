import React from 'react'; 

import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import Home from './screens/Home';
import Camera from './screens/Camera';
 

const Tab = createBottomTabNavigator();
function TabNavigator() { 
  return (
    <Tab.Navigator
      screenOptions={{headerShown: false}}
    >
      <Tab.Screen name="Home" component={Home} /> 
      <Tab.Screen name="Camera" component={Camera} /> 
    </Tab.Navigator>
  );
}





const DefaultStack = createNativeStackNavigator();
function DefaultStackNavigator() {
  return (
    <DefaultStack.Navigator screenOptions={{headerShown: false}} >
      <DefaultStack.Screen name="Default" component={TabNavigator} />
    </DefaultStack.Navigator>
  );
}



export default function Navigation() {
  return (
    <NavigationContainer >
      <DefaultStackNavigator />
    </NavigationContainer>
  );
}
