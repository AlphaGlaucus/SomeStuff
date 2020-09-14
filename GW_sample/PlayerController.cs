using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(UIHandler))]
public class PlayerController : MonoBehaviour
{

    public Action OnShoot;

    public Action OnShootGunOne;
    public Action OnShootGunTwo;
    public Action OnShootGunThree;
    public Action OnShootGunFour;

    public InfoHolder infoHolder;

    [SerializeField]
    private float speed = 7f;
    
    private UIHandler uiHandler;

    [HideInInspector]
    public ShotHandler shotHandler;

    private RectTransform leftStick;
    private RectTransform rightStick;

    [SerializeField]
    private Transform player;

    [SerializeField]
    private Transform gunEmptyObjPlace;


    public GameObject currentGun;
    private bool canCurrentGunFire;

    public enum GUNS
    {
        PeaGun,
        ChilliGun,
        ChestnutGun,
        MeshedPotatoesGun,
        CornGun,
        OnionGun,
        PumpkinGun,

        CherryGun,
        BlueberryGun,
        LemonGun,
        WineGun,
        WatermelonGun,
        BananaGun,
        DurianGun,

        VacuumCleanerGun,

    }


    private void Awake()
    {

        uiHandler = this.GetComponent<UIHandler>();
//        shotHandler = this.GetComponent<ShotHandler>();
        leftStick = uiHandler.GetLeftStick();
        rightStick = uiHandler.GetRightStick();

    }



    private void FixedUpdate()
    {
        ComputeMovement();
        ComputeShooting();
    }



    private void ComputeShooting()
    {        
        if (uiHandler.rightTouchID != -1)
        {
            gunEmptyObjPlace.eulerAngles = Vector3.forward * ComputeJoyStickAngle(rightStick);


            if (currentGun.GetComponent<Gun>().canFire)
            {     
//                if (OnShoot != null)
                OnShoot.Invoke();
            }
        }
    }

    private void ComputeMovement()
    {
        if (uiHandler.leftTouchID != -1)
        {
            player.eulerAngles = Vector3.forward * ComputeJoyStickAngle(leftStick);

            Vector3 movement = ComputeRelativeLeftDistance(leftStick) * speed * Vector3.right * Time.deltaTime;

            player.Translate(movement);
        }
    }

    private float ComputeRelativeLeftDistance(RectTransform stick) 
    {
        return Vector2.SqrMagnitude(stick.anchoredPosition) / (uiHandler.allowedRadius * uiHandler.allowedRadius);
    }

    private float ComputeJoyStickAngle(RectTransform stick)
    {
        return Mathf.Atan2(stick.anchoredPosition.y, stick.anchoredPosition.x) * Mathf.Rad2Deg;
        
    }

    public void SetCurrentGun(int gunNumber)
    {
        if (gunNumber == 0)
            OnShoot = OnShootGunOne;
        else if (gunNumber == 1)
            OnShoot = OnShootGunTwo;
        else if (gunNumber == 2)
            OnShoot = OnShootGunThree;
        else if (gunNumber == 3)
            OnShoot = OnShootGunFour;

        if (currentGun != null)
            currentGun.SetActive(false);


        currentGun = shotHandler.availableGuns[gunNumber];
        currentGun.SetActive(true);
        currentGun.GetComponent<Gun>().OnSwap();
    }



    public Transform GetEmptyObjPlace()
    {
        return gunEmptyObjPlace;
    }


}

