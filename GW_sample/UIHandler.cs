using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

[RequireComponent(typeof(PlayerController))]
public class UIHandler : MonoBehaviour
{

    PlayerController pc;


    [SerializeField]
    GameObject player;
    [SerializeField] 
    private RectTransform leftStick;
    [SerializeField] 
    private RectTransform rightStick;
    [SerializeField]
    private RectTransform healthBar;


    private GameObject leftJoy;
    private GameObject rightJoy;
    private GameObject[] gunBtn;



    private Vector2 leftJoyCenter;
    private Vector2 rightJoyCenter;
    private float joyDiameter;
    public float allowedRadius { get; private set; }


    private PointerEventData pointerEventData;
    private List<RaycastResult> raycastResults;


    public int leftTouchID { get; private set; }
    public int rightTouchID { get; private set; }

    
    private float aspectRationKoeficient;

    // hardcored canvas reference resolution 1920:1080
    private int canvasReferenceWidth = 1920;


    /// <summary>
    /// The current gun number. Can obtain number zero to three. Shows the current holding gun based on 
    /// the gun that is bounded and pressed on the current gun button
    /// </summary>
    private int currentGunNumber = 0;


    private void Awake()
    {       
        InitializeVariables();

        player.GetComponent<Player>().OnHealthChanged += UpdateHeathBar;

    }

    private void Update()
    {
        TrackTouches();
    }

    private void UpdateHeathBar(float currentHealth)
    {
        healthBar.localScale = new Vector3(currentHealth, 1, 1);

    }



    private void InitializeVariables()
    {

        pc = this.GetComponent<PlayerController>();
        

        pointerEventData = new PointerEventData(EventSystem.current);
        raycastResults = new List<RaycastResult>();

        aspectRationKoeficient = this.computeAspectRationKoeficient();

        leftJoy = GameObject.FindGameObjectWithTag("LeftJoy");
        rightJoy = GameObject.FindGameObjectWithTag("RightJoy");

        gunBtn = new GameObject[4];

        for(int i =0; i<4; i++)
        {
            gunBtn[i] = GameObject.Find("GunBtn" + i);
        }


        leftJoyCenter = leftJoy.GetComponent<RectTransform>().anchoredPosition;
        rightJoyCenter = rightJoy.GetComponent<RectTransform>().anchoredPosition;
        joyDiameter = leftJoy.GetComponent<RectTransform>().sizeDelta.x;

        allowedRadius = (joyDiameter /2f) / 1.5f;

        leftTouchID = -1;
        rightTouchID = -1;


    }



    /// <summary>
    /// Handles all touches. Controlling UI elements. Supports multiple touching at the same time
    /// </summary>
    private void TrackTouches()
    {

        bool leftTouched = false;
        bool rightTouched = false;
        if (Input.touchCount > 0)
        {
            foreach (Touch t in Input.touches)
            {


                pointerEventData.position = t.position;
                raycastResults.Clear();

                EventSystem.current.RaycastAll(pointerEventData, raycastResults);

                // graphics rays hit smt
                if (raycastResults.Count > 0)
                {
                    foreach (RaycastResult rs in raycastResults)
                    {

                        Vector2 tAnchoredPosition = t.position * aspectRationKoeficient;

                        if (rs.gameObject == leftJoy)
                        {
                            leftTouched = true;
                            leftTouchID = t.fingerId;
                            UpdateStickPosition(leftStick, leftJoyCenter, tAnchoredPosition);
                        }


                        else if (rs.gameObject == rightJoy)
                        {
                            rightTouched = true;
                            rightTouchID = t.fingerId;
                            Vector2 anchoredPositionRelativeToRightBottom = new Vector2(tAnchoredPosition.x - canvasReferenceWidth, tAnchoredPosition.y);
                            UpdateStickPosition(rightStick, rightJoyCenter, anchoredPositionRelativeToRightBottom);

                        }

                        else if (currentGunNumber != 0 && rs.gameObject == gunBtn[0])
                        {
                            currentGunNumber = 0;
                            pc.SetCurrentGun(0);
                        }
                        else if (currentGunNumber !=  1 &&rs.gameObject == gunBtn[1])
                        {
                            currentGunNumber = 1;
                            pc.SetCurrentGun(1);
                        }
                        else if (currentGunNumber != 2 && rs.gameObject == gunBtn[2])
                        {
                            currentGunNumber = 2;
                            pc.SetCurrentGun(2);
                        }
                        else if (currentGunNumber != 3 && rs.gameObject == gunBtn[3])
                        {
                            currentGunNumber = 3;
                            pc.SetCurrentGun(3);
                        }



                    }
                }
            }
            TrackJoyTouches(leftTouched, rightTouched);
            
        }

        // if leftJoystick is not tracked, reset its position
        if (leftTouchID == -1)
            leftStick.anchoredPosition = new Vector2(0, 0);

        if(rightTouchID == -1)
            rightStick.anchoredPosition = new Vector2(0, 0);
    }





    private void TrackJoyTouches(bool leftTouched, bool rightTouched)
    {
        //left is being tracked
        if (leftTouchID != -1)
        {
            Touch t = FindTrackingTouch(leftTouchID);
            if (!leftTouched)
            {
                Vector2 tAnchoredPosition = t.position * aspectRationKoeficient;
                Vector2 dir = (tAnchoredPosition - leftJoyCenter);
                dir.Normalize();
                leftStick.anchoredPosition = dir * allowedRadius;
            }
            if (t.phase == TouchPhase.Ended || t.phase == TouchPhase.Canceled)
                leftTouchID = -1;

        }


        //right is being tracked
        if(rightTouchID != -1)
        {
            Touch t = FindTrackingTouch(rightTouchID);
            if (!rightTouched)
            {
                Vector2 tAnchoredPosition = t.position * aspectRationKoeficient;
                Vector2 anchoredPositionRelativeToRightBottom = new Vector2(tAnchoredPosition.x - canvasReferenceWidth, tAnchoredPosition.y);
                Vector2 dir = (anchoredPositionRelativeToRightBottom - rightJoyCenter);
                dir.Normalize();
                rightStick.anchoredPosition = dir * allowedRadius;
            }
            if (t.phase == TouchPhase.Ended || t.phase == TouchPhase.Canceled)
                rightTouchID = -1;
        }

    }




    /// <summary>
    /// Finds the Touch which is being tracked based on the fingerId
    /// </summary>
    /// <param name="fingerId"> Id of touch that is being tracked. </param>
    /// <returns> Tracked Touch </returns>
    private Touch FindTrackingTouch(int fingerId)
    {

        foreach(Touch t in Input.touches)
        {
            if (t.fingerId == fingerId)
                return t;           
        }

        // if there is no match, return empty Touch
        return new Touch();

    }



    private void UpdateStickPosition(RectTransform stick, Vector2 joyCenter, Vector2 tAnchoredPosition)
    {
        if (Vector2.Distance(joyCenter, tAnchoredPosition) > allowedRadius)
        {

            Vector2 dir = (tAnchoredPosition - joyCenter);
            dir.Normalize();
            stick.anchoredPosition = dir * allowedRadius;

        }
        else
            stick.anchoredPosition = tAnchoredPosition - joyCenter;


    }



    /// <summary>
    /// Returns reference aspect ratio koeficient. Assumes canvas width match
    /// </summary>
    /// <returns> AspectRatioKoeficient </returns>
    private float computeAspectRationKoeficient()
    {
        // reference width resolution
        return ((float)canvasReferenceWidth / Screen.width);

        //Debug.Log($"{ratio}  {Screen.width} {Screen.height}");
    
    }


    public RectTransform GetLeftStick()
    {
        return leftStick;
    }

    public RectTransform GetRightStick()
    {
        return rightStick;
    }



}
