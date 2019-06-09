import * as express from 'express';
import { firestore } from '../model/firestore';


const router = express.Router();

// Read All Item
router.get('/characters/', async (req, res, next) => {
  try {

    const querySnapshot = await firestore.collection('characters').get();
    const characters: any = [];
    // tslint:disable-next-line:no-void-expression
    await querySnapshot.forEach((doc) => {
      characters.push(doc.data());
    });
    res.json(characters);
  } catch (e) {
    next(e);
  }
});

router.get('/characters/:id', async (req, res, next) => {
  try {
    const characterId = req.params.id;
    firestore.collection('characters').doc(characterId)
    const characterRef = await firestore.collection('characters').doc(characterId).get();
    const character = characterRef.data();
    if (!character) {
      throw new Error("not found");
    }
    res.json(character);
  } catch (e) {
    next(e);
  }
});

// Error Handling
router.use((req, res, next) => {
  res.status(404).json({
    error: 'Route Not Found'
  });
});



export default router;