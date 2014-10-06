package com.example.kinagafuji.gocci;


import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.support.v4.app.FragmentActivity;
import android.widget.TextView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.UiSettings;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;


public class Search_MapActivity extends FragmentActivity {

    private GoogleMap mMap = null;


    private SwipeRefreshLayout mSwipeRefreshLayout;

    double Latitude1;

    double Longitude1;

    private String MapURL;

    private static final String TAG_TELL = "tell";
    private static final String TAG_RESTNAME1 = "restname";
    private static final String TAG_CATEGORY = "category";
    private static final String TAG_LAT = "lat";
    private static final String TAG_LON = "lon";
    private static final String TAG_LOCALITY = "locality";
    private static final String TAG_DISTANCE = "distance";

    String tell;
    String restname;
    String category;
    Double lat;
    Double lon;
    String locality;
    String distance;


    ProgressDialog pDialog;

    static boolean isXLargeScreen = false;

    ArrayList<User> users = new ArrayList<User>();
    User user;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search__map);

        setUpMapIfNeeded();

        isXLargeScreen = isXLargeScreen();
        // SwipeRefreshLayoutの設定
        mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.refresh);
        mSwipeRefreshLayout.setOnRefreshListener(mOnRefreshListener);
        mSwipeRefreshLayout.setColorSchemeColors(Color.GRAY, Color.CYAN, Color.MAGENTA, Color.BLACK);

        new MyMapAsync().execute(MapURL);
        System.out.println(MapURL);
        // Showing progress dialog before sending http request
        pDialog = new ProgressDialog(this);
        pDialog.setMessage("Please wait..");
        pDialog.setIndeterminate(true);
        pDialog.setCancelable(false);
        pDialog.show();


    }

    private void setUpMapIfNeeded() {

        if (mMap == null) {
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map)).getMap();

            if (mMap != null) {
                setUpMap();
            }
        }
    }

    private void setUpMap() {

        mMap.setMyLocationEnabled(true);

        LocationManager locationManager = (LocationManager) getSystemService(LOCATION_SERVICE);

        Criteria criteria = new Criteria();

        String provider = locationManager.getBestProvider(criteria, true);

        Location myLocation = locationManager.getLastKnownLocation(provider);

        mMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);

        Latitude1 = myLocation.getLatitude();

        Longitude1 = myLocation.getLongitude();

        Log.d("経度・緯度", Latitude1 + "/" + Longitude1);

        MapURL = "https://codelecture.com/gocci/?lat=" + String.valueOf(Latitude1) + "&lon=" + String.valueOf(Longitude1) + "&limit=30";

        LatLng latLng = new LatLng(Latitude1, Longitude1);

        mMap.moveCamera(CameraUpdateFactory.newLatLng(latLng));

        mMap.animateCamera(CameraUpdateFactory.zoomTo(15));

        // MyLocationButtonを有効に
        UiSettings settings = mMap.getUiSettings();
        settings.setMyLocationButtonEnabled(true);


    }

    public class MyMapAsync extends AsyncTask<String, String, String> {


        String data;

        @Override
        protected String doInBackground(String... params) {

            HttpClient httpClient = new DefaultHttpClient();

            StringBuilder uri = new StringBuilder(MapURL);
            HttpGet request = new HttpGet(uri.toString());
            HttpResponse httpResponse = null;

            try {
                httpResponse = httpClient.execute(request);
            } catch (Exception e) {
                Log.d("JSONSampleActivity", "Error Execute");

            }

            int status = httpResponse.getStatusLine().getStatusCode();

            if (HttpStatus.SC_OK == status) {
                try {
                    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                    httpResponse.getEntity().writeTo(outputStream);
                    data = outputStream.toString(); // JSONデータ
                    Log.d("data", data);


                } catch (Exception e) {
                    Log.d("JSONSampleActivity", "Error");
                }


                try {


                    JSONArray jsonArray = new JSONArray(data);

                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject jsonObject = jsonArray.getJSONObject(i);

                        tell = jsonObject.getString(TAG_TELL);
                        restname = jsonObject.getString(TAG_RESTNAME1);
                        category = jsonObject.getString(TAG_CATEGORY);
                        lat = jsonObject.getDouble(TAG_LAT);
                        lon = jsonObject.getDouble(TAG_LON);
                        locality = jsonObject.getString(TAG_LOCALITY);
                        distance = jsonObject.getString(TAG_DISTANCE);


                        Log.d("String", tell + "/" + restname + "/" + category + "/" + lat + "/" + lon + "/" + locality + "/" + distance);

                        user = new User();

                        user.setTell(tell);
                        user.setRestname(restname);
                        user.setCategory(category);
                        user.setLat(lat);
                        user.setLon(lon);
                        user.setLocality(locality);
                        user.setDistance(distance);

                        users.add(user);


                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Log.d("えらー", String.valueOf(e));
                }


            } else {
                Log.d("JSONSampleActivity", "Status" + status);


            }

            return data;

        }


        // このメソッドは非同期処理の終わった後に呼び出されます
        @Override
        protected void onPostExecute(String data) {

            pDialog.dismiss();

            UserAdapter userAdapter = new UserAdapter(Search_MapActivity.this, 0, users);

            ListView maplv = (ListView) findViewById(R.id.mylistView1);
            maplv.setAdapter(userAdapter);

            maplv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int pos, long id) {


                    User country = users.get(pos);

                    ListView listView = (ListView) parent;


                    Intent intent = new Intent(Search_MapActivity.this, TenpoActivity.class);

                    intent.putExtra("restname", country.getRestname());

                    intent.putExtra("locality", country.getLocality());

                    startActivity(intent);
                }
            });


        }

    }

    private SwipeRefreshLayout.OnRefreshListener mOnRefreshListener = new SwipeRefreshLayout.OnRefreshListener() {
        @Override
        public void onRefresh() {
            // 3秒待機
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    mSwipeRefreshLayout.setRefreshing(false);
                }
            }, 3000);
        }
    };

    public boolean isXLargeScreen() {
        int layout = getResources().getConfiguration().screenLayout;
        return (layout & Configuration.SCREENLAYOUT_SIZE_MASK)
                == Configuration.SCREENLAYOUT_SIZE_XLARGE;
    }

    public static class ViewHolder {
        TextView tell;
        TextView restname;
        TextView category;
        TextView locality;
        TextView distance;

        public ViewHolder(View view) {
            this.tell = (TextView) view.findViewById(R.id.tell);
            this.restname = (TextView) view.findViewById(R.id.restname);
            this.category = (TextView) view.findViewById(R.id.category);
            this.locality = (TextView) view.findViewById(R.id.locality);
            this.distance = (TextView) view.findViewById(R.id.distance);
        }
    }

    public class UserAdapter extends ArrayAdapter<User> {
        private LayoutInflater layoutInflater;

        public UserAdapter(Context context, int viewResourceId, ArrayList<User> users) {
            super(context, viewResourceId, users);
            this.layoutInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            ViewHolder viewHolder;

            if (convertView == null) {
                convertView = layoutInflater.inflate(R.layout.maplist, null);
                viewHolder = new ViewHolder(convertView);
                convertView.setTag(viewHolder);
            } else {
                viewHolder = (ViewHolder) convertView.getTag();
            }

            final User user = this.getItem(position);


            LatLng latLng1 = new LatLng(user.getLat(), user.getLon());
            MarkerOptions options = new MarkerOptions();
            options.position(latLng1);
            options.title(user.getRestname());
            options.draggable(false);
            mMap.addMarker(options);
            mMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
                @Override
                public boolean onMarkerClick(Marker marker) {
                    return false;
                }
            });

            viewHolder.tell.setText(user.getTell());
            viewHolder.restname.setText(user.getRestname());
            viewHolder.category.setText(user.getCategory());
            viewHolder.locality.setText(user.getLocality());
            viewHolder.distance.setText(user.getDistance());


            return convertView;
        }
    }

    public class User {
        private String tell;
        private String restname;
        private String category;
        private Double lat;
        private Double lon;
        private String locality;
        private String distance;


        public String getTell() {
            return this.tell;
        }

        public void setTell(String tell) {
            this.tell = tell;
        }

        public String getRestname() {
            return this.restname;
        }

        public void setRestname(String restname) {
            this.restname = restname;
        }

        public String getCategory() {
            return this.category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public Double getLat() {
            return this.lat;
        }

        public void setLat(Double lat) {
            this.lat = lat;
        }

        public Double getLon() {
            return this.lon;
        }

        public void setLon(Double lon) {
            this.lon = lon;
        }

        public String getLocality() {
            return this.locality;
        }

        public void setLocality(String locality) {
            this.locality = locality;
        }

        public String getDistance() {
            return this.distance;
        }

        public void setDistance(String distance) {
            this.distance = distance;
        }


    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.search__map, menu);

        return super.onCreateOptionsMenu(menu);
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_search__map) {
            Intent intent = new Intent(this, TenpoActivity.class);
            startActivity(intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}


