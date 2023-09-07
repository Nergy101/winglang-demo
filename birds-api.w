bring cloud;
bring ex;
bring util;

// let redis = new ex.Redis();

let db = new ex.Table(
  name: "birds",
  primaryKey: "id",
  columns: {
    "name" => ex.ColumnType.STRING,
    "age" => ex.ColumnType.NUMBER
  }
);

let clientIdSecret = new cloud.Secret(
  name: "client-id"
);

let addBird = new cloud.Function(inflight (payload: str): str => {
    let data = Json.parse(payload);
    let guid = util.uuidv4();
    log("bird id: '${guid}'");
    log("bird data: '${payload}'");
    log("bird data: '${Json.parse(payload)}'");

    db.insert(guid, Json.parse(payload));
    // redis.set("birds:${guid}", str.fromJson(payload));

    log("added bird: '${payload}'");
    return guid;
}) as "AddBird";


let removeBird = new cloud.Function(inflight (payload: str) => {
    log("deleting bird: '${payload}'");

    db.delete(payload);
    // redis.del("birds:${payload}");
    log("deleted bird: '${payload}'");
}) as "RemoveBird";

let getBird = new cloud.Function(inflight (payload: str): Json => {
    log("getting bird: '${payload}'");

    let bird: Json = db.get(payload);
    // let bird = redis.get("birds:${payload}");
    log("got bird: '${bird}'");
    return bird;
    // return bird;
}) as "GetBird";

let api = new cloud.Api();


api.get("/birds/{id}", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    let id = request.vars.get("id");

    if id != "" {
      let birdData = getBird.invoke(id);
      
      return cloud.ApiResponse {
        status: 200,
        body: birdData
      };
    }

    return cloud.ApiResponse {
      status: 204
    };
});

api.post("/birds", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
  let clientId = clientIdSecret.value();
    log(clientId);

   if let body = request.body {
    let createdBirdId = addBird.invoke(body);

    return cloud.ApiResponse {
      status: 201,
      body: createdBirdId
    };
   }
});


api.delete("/birds/{id}", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    let id = request.vars.get("id");

    if id != "" {
      removeBird.invoke(id);
    }

    return cloud.ApiResponse {
      status: 204
    };
});


let website = new cloud.Website(path: "./public");

website.addJson("config.json", Json {
  "apiUrl": api.url,
  "title": "Wing-Birds"
});

