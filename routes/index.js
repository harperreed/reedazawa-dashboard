var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.io.emit("socketToMe", req.query.text );
  res.render('index', { title: 'Express' });
});

module.exports = router;
