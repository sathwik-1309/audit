import React from 'react'

function ProfilePic(props) {
  return (
    <img src={props.src} style={{
        height: props.height,
        width: props.height,
        borderRadius: '50%',
        margin: '0.6rem'
    }}/>
  )
}

export default ProfilePic