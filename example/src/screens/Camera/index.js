import React  from 'react';
import { StyleSheet, View } from 'react-native';
import InstaScan from 'react-native-instascan';

export default function Camera() {
  
  return (
    <View style={styles.container}>
      <InstaScan apiKey="fBjYzfbJTHx+5VIcEQLsEBCnNoAZksLw6TtHTUV/LOI="
        onPincodeRead = {data => console.log("pincode read: " + JSON.stringify(data))}
        onInstaScanError = {data => console.log("sdk error: " + JSON.stringify(data))}
      /> 
    </View>
  )
}



const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
